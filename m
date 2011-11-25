From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 15:05:41 -0500 (EST)
Message-ID: <20111125.150541.1523775319047816228.davem@davemloft.net>
References: <1322246442.2839.358.camel@deadeye>
	<20111125.135022.2150651060225144120.davem@davemloft.net>
	<1322249863.2839.375.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728Ab1KYUG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 15:06:59 -0500
In-Reply-To: <1322249863.2839.375.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 25 Nov 2011 19:37:43 +0000

> On Fri, 2011-11-25 at 13:50 -0500, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Fri, 25 Nov 2011 18:40:42 +0000
>> 
>> > On Fri, 2011-11-25 at 13:22 -0500, David Miller wrote:
>> >> Try allmodconfig for yourself.
>> > 
>> > OK, on x86_64, this does end up with PHYLIB=y but only because
>> > NET_DSA=y.  And I don't believe NET_DSA is appropriate for a distro
>> > kernel.
>> 
>> Do you think we can modularize the NET_DSA reference somehow?
> 
> Maybe, but I just don't care about DSA.  It requires platform data to
> work, so AFAICS it's only useful in a custom kernel for some platform
> that has one of the supported chips.

As far as I understand it, that's not true in the case of device tree,
which can instantiate the platform information dynamically.

And, in any event, having only one specific case force PHYLIB to 'y' is
at best disappointing.
