From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 12:17:33 +0200
Message-ID: <20070831101733.GA3108@ff.dom.local>
References: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51268 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755604AbXHaKQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 06:16:10 -0400
Content-Disposition: inline
In-Reply-To: <46D7E050.1030303@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 01:33:04PM +0400, Badalian Vyacheslav wrote:
> 
> >>i not have testing mashine.
> >>we have 2 mashine and dynamic routing. if 1 mashine down - all traffic 
> >>go to second mashine.
> >>I can test is on this mashines but i need that testing mashine will 
> >>reboot on kernel panic (sysctl message). No freezes =)
> >>
> >>Ok. i try 2.6.23-rc4.
> >>    
> >
> >...but without testing machine it can be too much risk! New versions
> >of kernel can break your applications (sometimes they should be at
> >least rebuilded).
> >
> >So, maybe you would better try this, 'less testing', version of my patch:
> >
> >  
> I risk only if RC kernel broke hardware. Mashines use only iptables and 
> TC. All Scrips backuped.

But sometime a new kernel can break binary compatibility with previous
one (e.g. after data structures change) and e.g. iptables or iproute
tools stop working or work in an unpredictable way. There were a few
such changes before 2.6.20 - I don't track current changes too much.
And I'm sure your system uses much more than iptables or TC, even
without your knowledge.

> But if i need to reboot PC by hand (if it freeze) i need drive to 
> servers-room =)

Of course, if previous kernel always boots by default, or even there
is a possibility to use for testing different partition with a copy
of main system this risk should be much smaller.

> 
> > BTW, I think after this BUG could be something more about other CPUs.
> > Could you check this?
> 
> I send to you all info that catch NETCONSOLE. i don't cut any info...

So, it seems something was broken. But, I meant, there can be sometimes
interesting things a few lines before or after the infos too.

> 
> Now 1 mashine work at *"2.6.23-rc4-git2 
> <http://kernel.org/pub/linux/kernel/v2.6/snapshots/patch-2.6.23-rc4-git2.bz2>" 
> Backup mashine use 2.6.18*
> 

BTW, -git versions are usually more risky than -rc. And, maybe, let
this 2.6.18 better stay away from this testing...

Thanks,
Jarek P.
