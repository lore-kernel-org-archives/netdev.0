From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 10:44:57 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1112161043080.26765@router.home>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>  <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
 <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:46262 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751994Ab1LPQpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 11:45:00 -0500
In-Reply-To: <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011, Eric Dumazet wrote:

> > Also I did it because ipv6 has per interface stats.
>
> I was considering _removing_ them, or make it optional.
>
> Memory costs are huge for percpu data.
>

And these costs are going to increase as we add more processors. Intel is
talking about hundred in the future.

So maybe we need to change the per cpu subsystem to be able to allocate
these only for subsets of cpus and then only allow the operation of
the network subsystems on the same subset? That would also increase cache
hotness. Pretty radical but I think at some point we will have to consider
that given that the number of cpus keep growing.
