From: Kieran Kunhya <kierank@ob-encoder.com>
Subject: Re: bnx2 udp multicast packet loss and jtter
Date: Fri, 17 Jun 2011 16:35:58 +0100
Message-ID: <BANLkTimNG0Tk4iPEZTMnUXpaZxcR3ZkLVw@mail.gmail.com>
References: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
	<1308324641.3539.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49314 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab1FQPf7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 11:35:59 -0400
Received: by ywe9 with SMTP id 9so1325095ywe.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 08:35:58 -0700 (PDT)
In-Reply-To: <1308324641.3539.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2011 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Le samedi 11 juin 2011 =E0 15:32 +0100, Kieran Kunhya a =E9crit :
> > Hello,
> >
> > I get some bad packet loss and high jitter on a BCM5709. This is on
> > kernel 2.6.38-8 - unfortunately using a newer kernel isn't an optio=
n
> > right now.
> > The bnx2 driver is version v2.0.23b.
> >
> > I've tried a lot of kenel types such as -lowlatency, -ck and vanill=
a.
> > The thread doing the udp output is at realtime priority and the sam=
e
> > thing happens with different applications.
> >
> > Example of jitter
> > http://dl.dropbox.com/u/2701213/jitter.png
> >
> > Is there anything I can do to further diagnose this problem?
> >
>
> Hi
>
> How is this jitter measured ?
>
> Is the link otherwise idle, or do you have a particular qdisc setup t=
o
> make sure packets from other flow wont have an effect ?

Thanks for the reply.
The jitter is measured with an IPTV analyser. There are other devices
on the same switch which don't have any jitter issues.
The link is otherwise idle.
