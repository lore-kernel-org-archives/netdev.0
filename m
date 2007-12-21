From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 09:21:06 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712210919350.30982@kivilampi-30.cs.helsinki.fi>
References: <476B574E.80601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_courier-4287-1198221666-0001-2"
Cc: "David S. Miller" <davem@davemloft.net>,
	"=?UTF-8?B?WU9TSElGVUpJIEhpZGU=?= =?UTF-8?B?YWtpIC8g5ZCJ6Jek6Iux5piO?="
	<yoshfuji@linux-ipv6.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38660 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbXLUHVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 02:21:10 -0500
In-Reply-To: <476B574E.80601@cosmosbay.com>
Content-ID: <Pine.LNX.4.64.0712210919351.30982@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_courier-4287-1198221666-0001-2
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-ID: <Pine.LNX.4.64.0712210919352.30982@kivilampi-30.cs.helsinki.fi>

On Fri, 21 Dec 2007, Eric Dumazet wrote:

> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces compiler
> to emit an integer divide, while we can help it to use a right shift,
> less expensive.

Can't you just change tot_len to unsigned here? It's just sizeof and some 
positive constants added...

-- 
 i.
--=_courier-4287-1198221666-0001-2
Content-Type: text/plain; name="tcp_ipv6.patch"; charset=iso-8859-1
Content-Transfer-Encoding: base64
Content-ID: <Pine.LNX.4.64.0712210919353.30982@kivilampi-30.cs.helsinki.fi>
Content-Description: 
Content-Disposition: inline; filename=tcp_ipv6.patch

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5j
CmluZGV4IDAyNjhlMTEuLjkyZjBmZGEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2
LmMKKysrIGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtMTEyNCw3ICsxMTI0LDcgQEAgc3Rh
dGljIHZvaWQgdGNwX3Y2X3NlbmRfYWNrKHN0cnVjdCB0Y3BfdGltZXdhaXRfc29jayAqdHcs
CiAJbWVtc2V0KHQxLCAwLCBzaXplb2YoKnQxKSk7CiAJdDEtPmRlc3QgPSB0aC0+c291cmNl
OwogCXQxLT5zb3VyY2UgPSB0aC0+ZGVzdDsKLQl0MS0+ZG9mZiA9IHRvdF9sZW4vNDsKKwl0
MS0+ZG9mZiA9IHRvdF9sZW4gPj4gMjsKIAl0MS0+c2VxID0gaHRvbmwoc2VxKTsKIAl0MS0+
YWNrX3NlcSA9IGh0b25sKGFjayk7CiAJdDEtPmFjayA9IDE7Cg==
--=_courier-4287-1198221666-0001-2--
