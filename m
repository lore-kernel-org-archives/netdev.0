From: David Miller <davem@davemloft.net>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 14:09:22 -0700 (PDT)
Message-ID: <20080919.140922.131706817.davem@davemloft.net>
References: <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
	<20080919181840.GE30956@parisc-linux.org>
	<36D9DB17C6DE9E40B059440DB8D95F520632FB45@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, netdev@vger.kernel.org, arjan@infradead.org,
	brice@myri.com, bhutchings@solarflare.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbYISVJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 17:09:34 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520632FB45@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Fri, 19 Sep 2008 13:57:58 -0700

> set multiqueue capabilities:
> ethtool -Q tx N rx N int <fixedcpu|pairs|somethingelse?>

No way.

Let irqbalanced implement the policy.  Just configure as many
queues as possible and let it figure out what to do.
