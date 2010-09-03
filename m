From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH net-2.6 2/3] be2net: fix a bug in UE detection logic
Date: Fri, 3 Sep 2010 10:25:08 +0530
Message-ID: <20100903045506.GA20511@serverengines.com>
References: <20100825102720.GA14925@serverengines.com>
 <20100825.142311.115915728.davem@davemloft.net>
 <20100825.211500.193701446.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:21873 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750761Ab0ICEyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 00:54:54 -0400
Content-Disposition: inline
In-Reply-To: <20100825.211500.193701446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/08/10 21:15 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 25 Aug 2010 14:23:11 -0700 (PDT)
> 
> > From: Ajit Khaparde <ajitk@serverengines.com>
> > Date: Wed, 25 Aug 2010 15:57:31 +0530
> > 
> >> The ONLINE registers can return 0xFFFFFFFF on more than one
> >> occassion. On systems that care, reading these registers could
> >> lead to problems.
> >> 
> >> So the new code decides that the ASIC has encountered and error
> >> by reading the UE_STATUS_LOW/HIGH registers. AND them with
> >> the mask values and a non-zero result indicates an error.
> >> 
> >> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> > 
> > Applied.
> 
> You didn't even build test what you submitted to me:
> 
> ERROR: "be_dump_ue" [drivers/net/benet/be2net.ko] undefined!
> 
> I'm reverting both patches.
Not sure why this happened and how I missed it because I did compile the
driver before sending the patches out. Will take care of this in future. Thanks
