From: Dave Boutcher <daveboutcher@gmail.com>
Subject: Re: [PATCH] e1000: fix loss of multicast packets
Date: Sun, 22 Mar 2009 13:05:19 -0500
Message-ID: <91bdcedb0903221105yafce0f4w1733a703c397bb7b@mail.gmail.com>
References: <20090320204415.25109.57486.stgit@lindenhurst-2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:35149 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbZCVSFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 14:05:22 -0400
Received: by yx-out-2324.google.com with SMTP id 31so1814533yxl.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2009 11:05:20 -0700 (PDT)
In-Reply-To: <20090320204415.25109.57486.stgit@lindenhurst-2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 3:44 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> This driver fix prepares an array all at once in memory and programs it in
> one shot to the hardware, not requiring an "erase" cycle.
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Dave Boutcher <daveboutcher@gmail.com>

Jesse, I just with this patch in my e1000 environment and it works
great.  Almost 1,000,000 packets exchanged with active
membership join/drops going on and no packets lost.  Thanks
for the fast turnaround.

Thanks,
-- 
Dave B
