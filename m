From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 20:41:14 +0300
Message-ID: <56953ABA.8020707@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru> <56953740.1090204@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp43.i.mail.ru ([94.100.177.103]:52485 "EHLO smtp43.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763709AbcALRlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 12:41:20 -0500
In-Reply-To: <56953740.1090204@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

12.01.2016 20:26, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> If it would be 0 the rfc1812 applies and
> should stop servers to send such redirects and clients to accept thos=
e.
Well, this is a very interesting point that
contradicts with all assumptions of the prev thread.
The assumptions were based on this document:
https://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/theconfvariables=
=2Ehtml
which says:
---
The shared_media setting tells the kernel if the physical network conne=
cted to a specific network card is a shared media or not. For example, =
if several different IP networks with different netmasks
operate over the same physical media or not.
*The main effect that this variable makes, is to tell the kernel whethe=
r it should send ICMP redirects to specific networks or not.*
---

But you seem to be saying that rfc1812 applies when it
is _disabled_ so the  ICMP redirects should still be sent,
just with the different rules.
So can you confirm that you imply the above document is wrong?
