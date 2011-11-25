From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 13:50:22 -0500 (EST)
Message-ID: <20111125.135022.2150651060225144120.davem@davemloft.net>
References: <1322230071.2839.337.camel@deadeye>
	<20111125.132220.150546128040363058.davem@davemloft.net>
	<1322246442.2839.358.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1KYSvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:51:35 -0500
In-Reply-To: <1322246442.2839.358.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 25 Nov 2011 18:40:42 +0000

> On Fri, 2011-11-25 at 13:22 -0500, David Miller wrote:
>> Try allmodconfig for yourself.
> 
> OK, on x86_64, this does end up with PHYLIB=y but only because
> NET_DSA=y.  And I don't believe NET_DSA is appropriate for a distro
> kernel.

Do you think we can modularize the NET_DSA reference somehow?
