From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2/2] forcedeth: mac address corrected
Date: Tue, 1 Aug 2006 09:17:09 -0400
Message-ID: <20060801131709.GC5965@gospo.rdu.redhat.com>
References: <44CE2A2D.9000103@nvidia.com> <20060801122727.GB5965@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:2704 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932074AbWHANSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 09:18:15 -0400
To: Andy Gospodarek <andy@greyhouse.net>
Content-Disposition: inline
In-Reply-To: <20060801122727.GB5965@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 08:27:27AM -0400, Andy Gospodarek wrote:
> On Mon, Jul 31, 2006 at 12:05:01PM -0400, Ayaz Abdulla wrote:
> > This patch will correct the mac address and set a flag to indicate that 
> > it is already corrected in case nv_probe is called again. For example, 
> > when you use kexec to restart the kernel.
> > 
> > Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> > 
> 
> Have you found other situations where this patch is critical other than
> when kevec is used to restart the kernel?
> 

s/kevec/kexec/g

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
