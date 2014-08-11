From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: Always untag vlan-tagged traffic on input.
Date: Mon, 11 Aug 2014 12:17:26 -0700 (PDT)
Message-ID: <20140811.121726.433178704630420349.davem@davemloft.net>
References: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, nsujir@broadcom.com,
	mchan@broadcom.com, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbaHKTR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 15:17:27 -0400
In-Reply-To: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevic@redhat.com>
Date: Fri,  8 Aug 2014 14:42:13 -0400

> Currently the functionality to untag traffic on input resides
> as part of the vlan module and is build only when VLAN support
> is enabled in the kernel.  When VLAN is disabled, the function
> vlan_untag() turns into a stub and doesn't really untag the
> packets.  This seems to create an interesting interaction
> between VMs supporting checksum offloading and some network drivers.
 ...
> The patch attempt to fix this another way.  It moves the vlan header
> stipping code out of the vlan module and always builds it into the
> kernel network core.  This way, even if vlan is not supported on
> a virtualizatoin host, the virtual machines running on top of such
> host will still work with VLANs enabled.
> 
> CC: Patrick McHardy <kaber@trash.net>
> CC: Nithin Nayak Sujir <nsujir@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks Vlad.
