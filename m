From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.31 08/10] wimax: Add netlink interface to get
 device state
Date: Thu, 28 May 2009 15:06:00 -0700 (PDT)
Message-ID: <20090528.150600.133260652.davem@davemloft.net>
References: <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
	<20090527182157.48a3f4b0@nehalam>
	<200905280916.23022.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, paulius.zaleckas@teltonika.lt
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57612
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751037AbZE1WGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 18:06:00 -0400
In-Reply-To: <200905280916.23022.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Thu, 28 May 2009 09:16:21 -0700

> Actually that's an extremely good point that I missed completely. 
> Thanks for catching it.
> 
> David, I'll submit an extra commit for correcting that point.

As I explained on IRC, it's better to repsin the patch set, putting
the bug fix into patch #8 discussed here, rather than to add a
follow-on fix for the bug.

This way the tree is properly bisectable.

Thanks.
