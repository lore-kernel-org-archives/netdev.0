From: "john" <johnp@marine-boy.nu>
Subject: Re: Problems getting a stable 100 megabit connection with linksys etherfast switch
Date: Thu, 4 Mar 2004 05:44:00 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040304123913.M97501@marine-boy.nu>
References: <20040229212053.M47845@spots.ca> <200403020001.48026.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Andrewm@uow.edu.au, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
In-Reply-To: <200403020001.48026.vda@port.imtp.ilyichevsk.odessa.ua>
List-Id: netdev.vger.kernel.org

Hi Denis,

Turns out I had a cable problem.  Some of the patch cables that I made, had
the wrong pinout.  After replacing them, the connection is stable at 100baseTx-FD.

Thanks

John



On Tue, 2 Mar 2004 00:01:47 +0200, Denis Vlasenko wrote
> On Sunday 29 February 2004 23:30, john wrote:
> > Hi,
> >
> > I am having problems getting a stable connection with my linux machines
> > when trying to connect them at 100 megabit speeds to a linksys etherfast
> > switch.
> >
> >
> > I have attached some diagnostic outputs for your review.  I hope that
> > someone can help me with this problem.
> >
> > I believe using a managed switch will solve the problem, but I don't want
> > to have to spend $1000.00 to fix this problem, when I should be able to
> > obtain a stable connection with the equipment I am currently using.
> 
> Try half duplex. You seldom do lots of xfers in both directions at 
> once, so half duplex is not a big loss.
> 
> Use tcpdump to see what's going on on the wire.
> --
> vda


--
