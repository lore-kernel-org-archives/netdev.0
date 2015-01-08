From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Thu, 08 Jan 2015 10:15:36 -0800
Message-ID: <1420740936.5947.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no>
	 <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no>
	 <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no>
	 <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
	 <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no>
	 <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
	 <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no>
	 <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no>
	 <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
	 <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com>
	 <34CE0233-F881-4F40-B119-AA9D8F7D500F@bengler.no>
	 <1420646284.5947.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no>
	 <1420666401.5947.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <DCC8B9AB-D1D7-4722-9B65-93AB5A559763@bengler.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erik Grinaker <erik@bengler.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34683 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310AbbAHSPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 13:15:39 -0500
In-Reply-To: <DCC8B9AB-D1D7-4722-9B65-93AB5A559763@bengler.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 17:47 +0000, Erik Grinaker wrote:

> FWIW, I've done a bisection, and it=E2=80=99s triggered by this chang=
e:
>=20
> https://github.com/torvalds/linux/commit/4e4f1fc226816905c937f9b29dab=
e351075dfe0f


This totally makes sense, thanks for doing the bisection !

>=20
> > We are not going to stick TCP stack to 20th century and buggy peers=
 or
> > middleboxes, sorry.
>=20
> That=E2=80=99s fair enough.

Strange thing is that sender does not misbehave at the beginning when
receiver window is still small. Only after a while.

It would be nice to know more details about sender OS/version.

Thanks.
