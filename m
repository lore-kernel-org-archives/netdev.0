From: "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Subject: AW: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 21:07:18 +0000
Message-ID: <3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>,<87r4jjav00.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:47961 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933178Ab3CMVHV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 17:07:21 -0400
In-Reply-To: <87r4jjav00.fsf@xmission.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> ________________________________________
> Von: Eric W. Biederman [ebiederm@xmission.com]
> Gesendet: Mittwoch, 13. M=E4rz 2013 21:46
> An: Martitz, Thomas
> Cc: richard -rw- weinberger; netdev@vger.kernel.org; davem@davemloft.=
net; edumazet@google.com; herbert@gondor.apana.org.au
> Betreff: Re: Trying to implement secondary loopback
>
> > I tried to implement an interface that's doesn't advertise as
> > such. But the data transfer didn't go through my code. My test app =
is
> > a simple client/server setup in a single process that sends/receive
> > data to/on 127.0.0.1.
>
> The easy solution is to setup two network namespaces and two nics.
> And transmit data from one network namespace to another, through your
> nics.
>
> Eric
>

That sounds a lot more involed than using loopback to send data back to=
 the same process. And I guess just calling netif_rx() in the xmit() fu=
nction wouldn't be sufficient either? Also I wouldn't know how to do th=
at as I'm not yet very familiar with network namespaces (but that can c=
learly get fixed).

Best regards.
-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 118=
07

www.hhi.fraunhofer.de/events
