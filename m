From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Fri, 31 Aug 2007 11:15:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708311112001.5681@x2>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53459 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758264AbXHaJQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:16:13 -0400
In-Reply-To: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Aug 2007, Stephen Hemminger wrote:

> There have been a lot of changes for 2.6.23, so here is a test release
> of iproute2 that should capture all the submitted patches
>
> Pavel Emelianov (1):
>      Make ip utility veth driver aware


Why does this add a new ip subcommand instead and uses genetlink
instead of the rtnl_link API, which was introduced exactly for
this stuff?
