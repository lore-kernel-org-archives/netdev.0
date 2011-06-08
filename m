From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [net-next 37/40] rtnetlink: Compute and store minimum ifinfo
 dump size
Date: Wed, 08 Jun 2011 08:09:57 +0200
Message-ID: <1307513397.3961.0.camel@jlt3.sipsolutions.net>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307449995-9458-38-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:35283 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab1FHGKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 02:10:06 -0400
In-Reply-To: <1307449995-9458-38-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 05:33 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The message size allocated for rtnl ifinfo dumps was limited to
> a single page.  This is not enough for additional interface info
> available with devices that support SR-IOV and caused a bug in
> which VF info would not be displayed if more than approximately
> 40 VFs were created per interface.
> 
> Implement a new function pointer for the rtnl_register service that will
> calculate the amount of data required for the ifinfo dump and allocate
> enough data to satisfy the request.

Curious. Weren't dumps supposed to be split up into small chunks and
then delivered? Where is this splitting going wrong, and could it be
improved to split into smaller pieces?

johannes

