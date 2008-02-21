From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:05:54 -0800 (PST)
Message-ID: <20080221.020554.259219477.davem@davemloft.net>
References: <1203586467.20345.14.camel@brick>
	<20080221.015743.222059206.davem@davemloft.net>
	<1203588079.20345.15.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58354
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751559AbYBUKFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:05:17 -0500
In-Reply-To: <1203588079.20345.15.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 21 Feb 2008 02:01:19 -0800

> In this case, it's being passed to a debugfs create function, could it
> instead use sysfs_format_mac?

Just assigning print_mac() to a local variable then passing that to
debugfs_create_dir() will make the warning go away.

>From another perspective adding that __pure attribute to print_mac()
might not have been the best idea.  But I can't think of another
way to elimitate the "passing print_mac() args to pr_debug()
still generates calls to print_mac() even when DEBUG is not
defined" problem :-/

