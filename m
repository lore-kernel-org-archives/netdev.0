From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Thu, 09 Apr 2015 02:24:31 -0700
Message-ID: <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
	 <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
	 <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35863 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933931AbbDIJYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 05:24:33 -0400
Received: by iebrs15 with SMTP id rs15so95875492ieb.3
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 02:24:33 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 19:09 +0200, Jan Engelhardt wrote:
> On Tuesday 2015-04-07 21:49, Eric Dumazet wrote:
> >> On Tuesday 2015-04-07 04:48, Eric Dumazet wrote:
> >> >On Tue, 2015-04-07 at 00:45 +0200, Jan Engelhardt wrote:
> >> >> I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
> [and now also 3.19.3]
> >> >> device makes IPv4-TCP transfers going into that veth-connected container 
> >> >> progress slowly.
> >> >
> >> >Nothing comes to mind. It would help if you could provide a script to
> >> >reproduce the issue.
> >> 
> >> It seems IPsec is *also* a requirement in the mix.
> >> Anyhow, script time!
> >
> >I tried your scripts, but the sender does not use veth ?
> 
> I was finally able to reproduce it reliably, and with just one 
> machine/kernel instance (and a number of containers of course).
> 
> I have uploaded the script mix to
> 	http://inai.de/files/tso-1.tar.xz
> There is a demo screencast at
> 	http://inai.de/files/tso-1.mkv

Thanks for providing these scripts, but they do not work on my host
running latest net-next

Basic IP routing seems not properly enabled, as even ping does not work
to reach 10.10.23.23

ip netns exec vclient /bin/bash
ping 10.10.23.23
<no frame is sent>

Have you tried net-next as well ?

Thanks
