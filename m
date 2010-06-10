From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] enic: cleanup vic_provinfo_alloc()
Date: Thu, 10 Jun 2010 11:32:30 +0200
Message-ID: <20100610093230.GM5483@bicker>
References: <20100610075903.GL5483@bicker> <4C10AEE9.4090804@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:62523 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab0FJJcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 05:32:41 -0400
Content-Disposition: inline
In-Reply-To: <4C10AEE9.4090804@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 10, 2010 at 11:22:49AM +0200, walter harms wrote:
> > +	vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
> > +	if (!vp)
> >  		return NULL;
> >  
> >  	memcpy(vp->oui, oui, sizeof(vp->oui));
> > --
> 
> 
> This looks like memdup() ?
> 

No.  VIC_PROVINFO_MAX_DATA is larger than sizeof(vp->oui).

regards,
dan carpenter

> re,
>  wh
