From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/4] net: support per queue tx_usecs in sysfs
Date: Tue, 01 Dec 2015 21:27:00 -0500 (EST)
Message-ID: <20151201.212700.1291998408162014445.davem@davemloft.net>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
	<565E1B8E.4040603@gmail.com>
	<20151201154454.000041a3@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, kan.liang@intel.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, andi@firstfloor.org,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, john.r.fastabend@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, dsahern@gmail.com, tj@kernel.org,
	cascardo@redhat.com, corbet@lwn.net
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473AbbLBC1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 21:27:04 -0500
In-Reply-To: <20151201154454.000041a3@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Tue, 1 Dec 2015 15:44:54 -0800

> While I agree that ethtool provides a similar functionality, ethtool
> was designed (particularly the ethtool -C/c commands) around one queue
> NICs.  We can't change the output or functionality of the user
> interface without breaking a bunch of user's scripts and stuff.

See my suggestion, we can encapsulate existing ethtool commands inside
of a new command that specifies operations that are to be applied to
specific queues.

Do not use sysfs for this.
