From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] at1700: fix double free_irq
Date: Fri, 9 Jul 2010 20:56:16 +0200
Message-ID: <20100709185616.GO19184@bicker>
References: <1278678686-7215-1-git-send-email-segooon@gmail.com> <20100709165817.GN19184@bicker> <20100709174809.GA5228@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43214 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab0GIS6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 14:58:14 -0400
Content-Disposition: inline
In-Reply-To: <20100709174809.GA5228@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 09, 2010 at 09:48:09PM +0400, Kulikov Vasiliy wrote:
> > >  	/* Disable the IRQ on boards of fmv18x where it is feasible. */
> >         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > It seems like this comment should be updated?
> 
> Maybe yes, but I don't know what these damn IO requests mean.
> Sure, it's better to request IRQ in xxx_open(), but as it is already
> done in probe() I leave it here.
> 
> If it is a bug then I do nothing with it, but if it is not then I'll
> create a bug.
> 

Yeah.  I see what you mean.  You are probably right.  It should be easy
to test if anyone had the hardware.  But this driver is 17 years old so
I doubt anyone does.  :P

regards,
dan carpenter
