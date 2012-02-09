From: David Miller <davem@davemloft.net>
Subject: Re: RFC for sysfs management of TIPC
Date: Thu, 09 Feb 2012 14:19:03 -0500 (EST)
Message-ID: <20120209.141903.1988391781467106278.davem@davemloft.net>
References: <0434463FDA60A94FA978ACA44617682DF7A43C76D1@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	allan.stephens@windriver.com, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, Ying.Xue@windriver.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140Ab2BITTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 14:19:16 -0500
In-Reply-To: <0434463FDA60A94FA978ACA44617682DF7A43C76D1@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 9 Feb 2012 14:14:12 -0500

> TIPC currently provides a netlink interface towards a user space 
> program (tipc-config), which is used to turn the different knobs
> and levers of TIPC. 
> This program is provided by some distributions package systems,
> and is also downloadable from SourceForge.
> 
> Now, we are considering the option of making the configuration 
> available as a structured tree in sysfs.

If you've already made the netlink mechanism for all of this,
do not bother with SYSFS.
