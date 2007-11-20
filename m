From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 06/11] netpoll: remove dev_name for npinfo
Date: Mon, 19 Nov 2007 20:07:39 -0800
Message-ID: <20071119200739.60bfb1f5@freepuppy.rosehill>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.747306412@linux-foundation.org>
	<20071119.194750.34466046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37100 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758524AbXKTEIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 23:08:25 -0500
In-Reply-To: <20071119.194750.34466046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Nov 2007 19:47:50 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Sat, 03 Nov 2007 11:43:20 -0700
> 
> > The device name was only in npinfo for netconsole target
> > configuration, so move it to netconsole.  Netconsole only
> > needs the value during config, so no need to do all
> > the device name tracking etc.. 
> > 
> > Make functions for common code for instantiation and 
> > start up.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Sigh...
> 
> 	return -EUNTESTED;
> 
> In netpoll_parse_options() np->dev isn't setup yet, so if you had
> tested this patch you would have gotten an immediate OOPS.

Sorry, I missed the boot up case, I was testing with modprobe
and dyanmic reconfig stuff.  Places that store the name (and then
get confused by renames) are one of the lingering mis-features of
the whole network device infrastructure. 


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
