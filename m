From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3 1/8] i40e: main driver core
Date: Fri, 30 Aug 2013 14:40:00 -0400 (EDT)
Message-ID: <20130830.144000.1005297116915822361.davem@davemloft.net>
References: <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377880368.2070.26.camel@joe-AO722>
	<20130830111029.25d6d753@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com, e1000-devel@lists.sourceforge.net
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab3H3SkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:40:03 -0400
In-Reply-To: <20130830111029.25d6d753@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 30 Aug 2013 11:10:29 -0700

> On Fri, 30 Aug 2013 09:32:48 -0700
> Joe Perches <joe@perches.com> wrote:
> 
>> > +static int debug = -1;
>> > +module_param(debug, int, 0);
>> > +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");  
>> 
>> Maybe make debug a bitfield instead?
> 
> No Joe, this is the standard mapping of debug to msglevel used
> by most network devices. The debug parameter is converted
> to mask by netif_msg_init.

Correct.
