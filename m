From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 11:29:57 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1112161128060.26765@router.home>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>    <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>    <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>   <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
  <alpine.DEB.2.00.1112161043080.26765@router.home>  <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1112161053030.26765@router.home> <1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:41385 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752189Ab1LPRaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 12:30:00 -0500
In-Reply-To: <1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011, Eric Dumazet wrote:

> >  Reduction of network processing to a set of processors also will
> > have other beneficial effects in addition to cache hotness. It would
> > removing OS jitter etc etc.
> >
>
> You already can do that right now, with or without hardware help.
>
> See numerous improvements in this area (RPS/RFS/RSS/XPS ... in
> Documentation/networking/scaling.txt)

I have some latency critical processes here and I wish I could get
networking in general off the processor where the latency sensitive stuff
is running should that process decide to do some calls that cause network
I/O.

Traditional networking is a slow process these days.
