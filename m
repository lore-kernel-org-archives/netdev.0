From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] ixgbe: fix panic due to uninitialized pointer
Date: Fri, 11 Feb 2011 16:56:45 -0500
Message-ID: <20110211215645.GA11864@gospo.rdu.redhat.com>
References: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Skidmore <donald.c.skidmore@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756843Ab1BKV4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 16:56:46 -0500
Content-Disposition: inline
In-Reply-To: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 11, 2011 at 04:45:47PM -0500, Andy Gospodarek wrote:
> Systems containing an 82599EB and running a backported driver from
> upstream were panicing on boot.  It turns out hw->mac.ops.setup_sfp is
> only set for 82599, so one should check to be sure that pointer is set
> before continuing in ixgbe_sfp_config_module_task.  I verified by
> inspection that the upstream driver has the same issue and also added a
> check before the call in ixgbe_sfp_link_config.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Corrected spelling error in Subject.
