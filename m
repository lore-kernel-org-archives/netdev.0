From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sun, 23 Jan 2011 11:48:26 -0800 (PST)
Message-ID: <20110123.114826.112588008.davem@davemloft.net>
References: <20110122.214254.226765382.davem@davemloft.net>
	<20110123192416.73cd7521@s6510>
	<20110123192624.5cfe33d0@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, ebiederm@xmission.com,
	jbohac@suse.cz, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab1AWTrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 14:47:52 -0500
In-Reply-To: <20110123192624.5cfe33d0@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 23 Jan 2011 19:26:24 +1100

> Also for application sanity, Linux should behave the same as BSD

I've heard enough, I'm reverting your changes.  You obviously
don't get what "don't break stuff that was working" means.
