From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with talking to the kernel and iproute2/ifconfig
Date: Thu, 25 Mar 2010 18:31:46 +0100
Message-ID: <4BAB9E02.2040605@trash.net>
References: <4BAB88A3.9070702@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050604010709000302090708"
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56318 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab0CYRbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:31:48 -0400
In-Reply-To: <4BAB88A3.9070702@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050604010709000302090708
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Paweł Staszewski wrote:
> Hello
> 
> I have strange problem with kernel 2.6.33.1
> 
> I have script with 6267 ip's
> 
> cat gateways.conf | grep 'addr add' | wc -l
> 6267
> 
> and when i want to commit this interfaces by command:
> ip -batch gateways.conf
> 
> I have only 680 ip interfaces
> ip a | grep inet | grep ' 10.' | wc -l
> 680
> 
> 
> I test this on kernels 2.6.29.1 and 2.6.30.1 and all was OK.
> on kernel 2.6.29.1
> 
> ip -batch gateways.conf
> ip a | grep inet | grep ' 10.' | wc -l
> 6267
> 
> on kernel 2.6.30.1
> ip -batch gateways.conf
> ip a | grep inet | grep ' 10.' | wc -l
> 6267

Does this patch help? When "idx" points to the last device
of a chain, it will never get incremented past s_idx and we
fail to reset s_ip_idx.


--------------050604010709000302090708
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2RldmluZXQuYyBiL25ldC9pcHY0L2RldmluZXQuYwpp
bmRleCA1MWNhOTQ2Li4zZmViMmIzIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9kZXZpbmV0LmMK
KysrIGIvbmV0L2lwdjQvZGV2aW5ldC5jCkBAIC0xMTk0LDcgKzExOTQsNyBAQCBzdGF0aWMg
aW50IGluZXRfZHVtcF9pZmFkZHIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldGxp
bmtfY2FsbGJhY2sgKmNiKQogCQlobGlzdF9mb3JfZWFjaF9lbnRyeV9yY3UoZGV2LCBub2Rl
LCBoZWFkLCBpbmRleF9obGlzdCkgewogCQkJaWYgKGlkeCA8IHNfaWR4KQogCQkJCWdvdG8g
Y29udDsKLQkJCWlmIChpZHggPiBzX2lkeCkKKwkJCWlmIChoID4gc19oIHx8IGlkeCA+IHNf
aWR4KQogCQkJCXNfaXBfaWR4ID0gMDsKIAkJCWluX2RldiA9IF9faW5fZGV2X2dldF9yY3Uo
ZGV2KTsKIAkJCWlmICghaW5fZGV2KQo=
--------------050604010709000302090708--
