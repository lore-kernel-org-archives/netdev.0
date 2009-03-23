From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: fix loss of multicast packets
Date: Mon, 23 Mar 2009 01:09:57 -0700 (PDT)
Message-ID: <20090323.010957.163908188.davem@davemloft.net>
References: <20090320204415.25109.57486.stgit@lindenhurst-2.jf.intel.com>
	<91bdcedb0903221105yafce0f4w1733a703c397bb7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: daveboutcher@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48945
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754917AbZCWIKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 04:10:09 -0400
In-Reply-To: <91bdcedb0903221105yafce0f4w1733a703c397bb7b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Boutcher <daveboutcher@gmail.com>
Date: Sun, 22 Mar 2009 13:05:19 -0500

> On Fri, Mar 20, 2009 at 3:44 PM, Jesse Brandeburg
> <jesse.brandeburg@intel.com> wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > This driver fix prepares an array all at once in memory and programs it in
> > one shot to the hardware, not requiring an "erase" cycle.
> >
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > CC: Dave Boutcher <daveboutcher@gmail.com>
> 
> Jesse, I just with this patch in my e1000 environment and it works
> great.  Almost 1,000,000 packets exchanged with active
> membership join/drops going on and no packets lost.  Thanks
> for the fast turnaround.

Thanks for testing Dave.

Intel folks, can we get this formally submitted soon?

Thanks.
