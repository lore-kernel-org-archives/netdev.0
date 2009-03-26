From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] e1000: fix close race with interrupt
Date: Thu, 26 Mar 2009 01:02:09 -0700 (PDT)
Message-ID: <20090326.010209.48338109.davem@davemloft.net>
References: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
	<20090326075922.30121.40411.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, alan@lxorguk.ukuu.org.uk,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756106AbZCZICV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:02:21 -0400
In-Reply-To: <20090326075922.30121.40411.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 00:59:22 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> this is in regards to
> http://bugzilla.kernel.org/show_bug.cgi?id=12876
> 
> where it appears that e1000 can leave its interrupt enabled after
> exiting the driver.  Fix the bug by making the interrupt enable
> paths more aware of the driver exiting.
> 
> Thanks to Alan Cox for the poke and initial investigation.
> 
> CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
