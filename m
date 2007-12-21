From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 07:03:58 +0100
Message-ID: <476B574E.80601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040803040204050906010803"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGU=?=
	 =?UTF-8?B?YWtpIC8g5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50694 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbXLUGEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 01:04:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040803040204050906010803
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces compiler
to emit an integer divide, while we can help it to use a right shift,
less expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------040803040204050906010803
Content-Type: text/plain;
 name="tcp_ipv6.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="tcp_ipv6.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5j
CmluZGV4IDAyNjhlMTEuLjkyZjBmZGEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2
LmMKKysrIGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtMTEyNCw3ICsxMTI0LDcgQEAgc3Rh
dGljIHZvaWQgdGNwX3Y2X3NlbmRfYWNrKHN0cnVjdCB0Y3BfdGltZXdhaXRfc29jayAqdHcs
CiAJbWVtc2V0KHQxLCAwLCBzaXplb2YoKnQxKSk7CiAJdDEtPmRlc3QgPSB0aC0+c291cmNl
OwogCXQxLT5zb3VyY2UgPSB0aC0+ZGVzdDsKLQl0MS0+ZG9mZiA9IHRvdF9sZW4vNDsKKwl0
MS0+ZG9mZiA9IHRvdF9sZW4gPj4gMjsKIAl0MS0+c2VxID0gaHRvbmwoc2VxKTsKIAl0MS0+
YWNrX3NlcSA9IGh0b25sKGFjayk7CiAJdDEtPmFjayA9IDE7Cg==
--------------040803040204050906010803--
