From: Andi Kleen <ak@suse.de>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Fri, 9 Jun 2006 07:50:25 +0200
Message-ID: <200606090750.25067.ak@suse.de>
References: <20060608210702.GD24227@waste.org> <4489038C.3050901@intel.com> <20060608.222352.59657133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeremy@goop.org, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:36550 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S965221AbWFIFut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:50:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060608.222352.59657133.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 June 2006 07:23, David Miller wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Thu, 08 Jun 2006 22:13:48 -0700
> 
> > netconsole should retry. There is no timeout programmed here since that might
> > lose important information, and you rather want netconsole to survive an odd
> > unplugged cable then to lose vital debugging information when the system is
> > busy for instance. (losing link will cause the interface to be down and thus
> > the queue to be stopped)
> 
> I completely disagree that netpoll should loop when the ethernet
> cable is plugged out. 

Currently it is a bit dumb and doesn't distingush the various cases
well.

I submitted a patch to loop to be a bit more clever at some point. It can be still
found in the netdev archives.

-Andi
