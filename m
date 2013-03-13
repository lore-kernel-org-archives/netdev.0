From: "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 20:38:08 +0000
Message-ID: <3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
References: <513F1A17.1000809@hhi.fraunhofer.de>,<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:52707 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933178Ab3CMUiL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 16:38:11 -0400
In-Reply-To: <CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> ________________________________________
> Von: richard -rw- weinberger [richard.weinberger@gmail.com]
> Gesendet: Mittwoch, 13. M=E4rz 2013 12:13
> An: Martitz, Thomas
> Cc: netdev@vger.kernel.org; davem@davemloft.net; edumazet@google.com;=
 herbert@gondor.apana.org.au; ebiederm@xmission.com
> Betreff: Re: Trying to implement secondary loopback
>
> >
> > So my questions are:
> > * Is this on purpose/expected?
> > * Is there anyway around it so that I can have a custom loopback in=
terface
> > without touching lo's functionality.
> > * Generally, what's the proper way (if any) implement a secondary l=
oopback
> > interface?
>
> The only really question that matters is, why do you need a second
> loopback interface?
> Why can't you use any other pseudo interface?
>

What pseudo interface do you mean? I'm not aware of alternative pseudo =
interfaces.

I'm developing a NIC and a driver for it. Thus I'm implementing the int=
erface. I'm trying to implement an interface that does exactly do what =
loopback does except that I want to extend the loopback path to PCIe. T=
his is for testing & validation purposes.

I tried to implement an interface that's doesn't advertise as such. But=
 the data transfer didn't go through my code. My test app is a simple c=
lient/server setup in a single process that sends/receive data to/on 12=
7.0.0.1.

Best regards.
-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 118=
07

www.hhi.fraunhofer.de/events
