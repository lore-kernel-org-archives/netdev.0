From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] make icmp_sk_init() static
Date: Mon, 21 Apr 2008 12:44:09 +0300
Message-ID: <20080421094409.GK26897@cs181133002.pp.htv.fi>
References: <20080421084845.GR26897@cs181133002.pp.htv.fi> <20080421.023226.237529768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: den@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:33710 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbYDUJoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 05:44:37 -0400
Content-Disposition: inline
In-Reply-To: <20080421.023226.237529768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2008 at 02:32:26AM -0700, David Miller wrote:
> From: Adrian Bunk <bunk@kernel.org>
>...
> BTW, I noticed that some of your patches get posted like
> this:
> 
> > d163a44e24881d5e960bf9bdc1819ba8ccd15555 diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> > index f064031..fee171e 100644
> 
> with the commit ID newline missing, so that the diff specification
> shares the same line as the commit ID.
> 
> Oddly some of your patch postings do not have this missing newline.
> 
> Any idea what causes this?  Just curious :-)

I'm using git mainly as a diff generation tool doing
  cg-commit < /dev/null; git-show --pretty=oneline > /tmp/patch-somename

This "commit ID newline missing" seems to be the effect of the 
--pretty=oneline.

Not sure why some postings do have the newline.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

