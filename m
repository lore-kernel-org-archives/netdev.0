From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Sun, 30 Sep 2012 21:45:30 +0200
Message-ID: <1349034330.12401.210.camel@edumazet-glaptop>
References: <5057455A.7050108@googlemail.com>
	 <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>
	 <1347979239.26523.267.camel@edumazet-glaptop>
	 <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>
	 <50643DA1.7070306@googlemail.com>
	 <1348748042.5093.1168.camel@edumazet-glaptop>
	 <50649567.2010704@googlemail.com>
	 <1348779826.5093.1750.camel@edumazet-glaptop>
	 <1348780624.5093.1767.camel@edumazet-glaptop>
	 <50656C4A.8090302@googlemail.com>
	 <1348831592.5093.2251.camel@edumazet-glaptop>
	 <5068648C.7050005@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61209 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab2I3Tpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 15:45:35 -0400
Received: by bkcjk13 with SMTP id jk13so4538190bkc.19
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2012 12:45:34 -0700 (PDT)
In-Reply-To: <5068648C.7050005@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-30 at 16:26 +0100, Chris Clayton wrote:
> Hi Eric,
> 
> On 09/28/12 12:26, Eric Dumazet wrote:
> > On Fri, 2012-09-28 at 10:22 +0100, Chris Clayton wrote:
> >
> >> No, the WinXP guest is configured with a fixed IP address
> >> (192.168.200.1). Subnet mask is 255.255.255.0, and default gateway is
> >> 192.168.200.254. DNS is 192.168.0.1.
> >>
> >
> > I have no problem with such a setup, with a linux guest.
> >
> > Could you send again a tcpdump, but including link-level header ?
> > (option -e)
> >
> > Ideally, you could send two traces, one taken on tap0, and another taken
> > on eth0.
> >
> Below are two more traces that I think may well be more useful than 
> those I sent on Friday. They are taken with tcpdump directly (after some 
> reading up on that application) rather than tcpdump translations of pcap 
> files captured with netsniff-ng. Also, they are taken concurrently, so 
> they show the traffic on tap0 and eth0 at the time of an unsuccessful 
> attempt to ping the router from the WinXP KVM client. The command was: 
> sudo tcpdump -nev -i eth0 -Z chris >eth0.trace


Could you send "netstat -s" before/after your tests ?
