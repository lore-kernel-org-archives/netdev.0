From: Dave Jones <davej@redhat.com>
Subject: Re: i40e: Add code to handle FD table full condition
Date: Fri, 4 Apr 2014 10:59:30 -0400
Message-ID: <20140404145930.GA20434@redhat.com>
References: <20140403052019.CFC67661245@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anjali.singhai@intel.com, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbaDDO7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 10:59:38 -0400
Content-Disposition: inline
In-Reply-To: <20140403052019.CFC67661245@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 05:20:19AM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=commit;h=55a5e60b9f583f64a6c95cfe869dd2d65ae53a95
 > Commit:     55a5e60b9f583f64a6c95cfe869dd2d65ae53a95
 > Parent:     61dade7e9201162cba683cff103cebbdf06655d4
 > Author:     Anjali Singhai Jain <anjali.singhai@intel.com>
 > AuthorDate: Wed Feb 12 06:33:25 2014 +0000
 > Committer:  Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 > CommitDate: Fri Mar 14 16:30:03 2014 -0700
 > 
 >     i40e: Add code to handle FD table full condition
 
...

 > +			/* Turn off ATR first */
 > +			if (pf->flags | I40E_FLAG_FD_ATR_ENABLED) {

This condition is always true.
Did you mean to write something like

	if (pf->flags & ~I40E_FLAG_FD_ATR_ENABLED)

perhaps ?

Same with the 

	} else if (pf->flags | I40E_FLAG_FD_SB_ENABLED) {

that pairs with it.


	Dave
