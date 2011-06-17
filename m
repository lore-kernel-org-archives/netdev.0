From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2 udp multicast packet loss and jtter
Date: Fri, 17 Jun 2011 17:52:44 +0200
Message-ID: <1308325964.3539.14.camel@edumazet-laptop>
References: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
	 <1308324641.3539.1.camel@edumazet-laptop>
	 <BANLkTimNG0Tk4iPEZTMnUXpaZxcR3ZkLVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kieran Kunhya <kierank@ob-encoder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62269 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759190Ab1FQPws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 11:52:48 -0400
Received: by wwe5 with SMTP id 5so604488wwe.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 08:52:47 -0700 (PDT)
In-Reply-To: <BANLkTimNG0Tk4iPEZTMnUXpaZxcR3ZkLVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 juin 2011 =C3=A0 16:35 +0100, Kieran Kunhya a =C3=A9crit=
 :
> On Fri, Jun 17, 2011 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > Le samedi 11 juin 2011 =C3=A0 15:32 +0100, Kieran Kunhya a =C3=A9cr=
it :
> > > Hello,
> > >
> > > I get some bad packet loss and high jitter on a BCM5709. This is =
on
> > > kernel 2.6.38-8 - unfortunately using a newer kernel isn't an opt=
ion
> > > right now.
> > > The bnx2 driver is version v2.0.23b.
> > >
> > > I've tried a lot of kenel types such as -lowlatency, -ck and vani=
lla.
> > > The thread doing the udp output is at realtime priority and the s=
ame
> > > thing happens with different applications.
> > >
> > > Example of jitter
> > > http://dl.dropbox.com/u/2701213/jitter.png
> > >
> > > Is there anything I can do to further diagnose this problem?
> > >
> >
> > Hi
> >
> > How is this jitter measured ?
> >
> > Is the link otherwise idle, or do you have a particular qdisc setup=
 to
> > make sure packets from other flow wont have an effect ?
>=20
> Thanks for the reply.
> The jitter is measured with an IPTV analyser. There are other devices
> on the same switch which don't have any jitter issues.
> The link is otherwise idle.

jitter has a precise meaning in RTP flows. Is this IPTV analyser using
this definition ?

Is this analyser running on the machine that sends frames, or another
machine ?

Are you sure the realtime thread fullfill its requirements ?
(RT priority wont help if this thread is cpu bounded)



