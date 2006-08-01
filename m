From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2/2] forcedeth: mac address corrected
Date: Tue, 1 Aug 2006 08:27:27 -0400
Message-ID: <20060801122727.GB5965@gospo.rdu.redhat.com>
References: <44CE2A2D.9000103@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:9430 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751158AbWHAMdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:33:07 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>
Content-Disposition: inline
In-Reply-To: <44CE2A2D.9000103@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 12:05:01PM -0400, Ayaz Abdulla wrote:
> This patch will correct the mac address and set a flag to indicate that 
> it is already corrected in case nv_probe is called again. For example, 
> when you use kexec to restart the kernel.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 

Have you found other situations where this patch is critical other than
when kevec is used to restart the kernel?

