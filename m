From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Thu, 8 Jan 2015 17:47:55 +0000
Message-ID: <DCC8B9AB-D1D7-4722-9B65-93AB5A559763@bengler.no>
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
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60117 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757165AbbAHRr6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 12:47:58 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 527FB20B37
	for <netdev@vger.kernel.org>; Thu,  8 Jan 2015 12:47:57 -0500 (EST)
In-Reply-To: <1420666401.5947.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07 Jan 2015, at 21:33, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-01-07 at 20:37 +0000, Erik Grinaker wrote:
> I agree. I have contacted Amazon about this, but am not too hopeful
>> for a quick fix; they have been promising SACK-support on their
>> loadbalancers since 2006, for example.
>>=20
>> That said, since this change breaks a service as popular as S3, it
>> might be worth reconsidering.
>=20
> Which change are you talking about ? Have you done a bisection to
> clearly identify the patch exposing this sender bug ?

=46WIW, I've done a bisection, and it=E2=80=99s triggered by this chang=
e:

https://github.com/torvalds/linux/commit/4e4f1fc226816905c937f9b29dabe3=
51075dfe0f

> We are not going to stick TCP stack to 20th century and buggy peers o=
r
> middleboxes, sorry.

That=E2=80=99s fair enough.