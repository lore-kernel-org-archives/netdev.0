From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: want to randomly drop packets based on percent
Date: Mon, 17 Apr 2006 09:46:34 -0700
Message-ID: <20060417094634.7191fea5@localhost.localdomain>
References: <444345F9.4090100@cmu.edu>
	<20060417091915.67e28361@localhost.localdomain>
	<4444171B.90507@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	matt.keenan@btinternet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59082 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750734AbWDQQqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:46:36 -0400
To: George Nychis <gnychis@cmu.edu>
In-Reply-To: <4444171B.90507@cmu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006 18:30:51 -0400
George Nychis <gnychis@cmu.edu> wrote:

> 
> 
> Stephen Hemminger wrote:
> 
> >On Mon, 17 Apr 2006 03:38:33 -0400
> >George Nychis <gnychis@cmu.edu> wrote:
> >
> >  
> >
> >>Hey,
> >>
> >>I'm using the 2.4.32 kernel with madwifi and iproute2 version 
> >>2-2.6.16-060323.tar.gz
> >>
> >>I wanted to insert artificial packet loss based on a percent so i found:
> >>network emulab qdisc could do it, so i compiled support into the kernel 
> >>and tried:
> >>tc qdisc change dev eth0 root netem loss .1%
             ^^^^^^

You need to do add not change. Add will set the queue discipline
to netem (default is pfifo_fast).  Change is for changing netem parameters
after it is loaded.
