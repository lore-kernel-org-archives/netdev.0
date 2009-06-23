From: Kengo Sakai <kengo.sakai@atr.jp>
Subject: Re: [QUESTION] About IPv6 flowlabel in a TCP IPv6 Server
Date: Tue, 23 Jun 2009 11:31:03 +0900
Message-ID: <4A403E67.8090906@atr.jp>
References: <4A36F751.6070306@atr.jp> <200906221145.40481.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1w.atr.jp ([133.186.1.10]:38541 "EHLO mailgw1.atr.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbZFWCdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 22:33:20 -0400
In-Reply-To: <200906221145.40481.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello R=E9mi,

Thanks for your mail.

R=E9mi Denis-Courmont wrote:
> On Tuesday 16 June 2009 04:37:21 ext Kengo Sakai wrote:
>> 2) Can a flowlabel be set to a sending packet in a TCP IPv6 Server?
>=20
> I don't understand your question. To me, you cannot send "packets", a=
t least=20
> not directly, via TCP sockets in the first place. Userland pushes dat=
a to the=20
> kernel buffers, and those buffers are segmented in some opaque (from =
userland)=20
> way. There is certainly no 1:1 matching of send() calls to packets.

Sorry, I mistook the expression.
I have understood that the data pushed from userland is segmented into
packets in kernel.

I want to set a flowlabel to packets into which kernel segment the data
which TCP IPv6 Server send(2) or write(2).
But I can't do it.

Do you have any idea?

Thanks,
Kengo

