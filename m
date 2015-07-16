From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH] bnx2x: Update to FW version 7.12.30
Date: Thu, 16 Jul 2015 11:20:10 -0400
Message-ID: <20150716152010.GC28956@merlin.infradead.org>
References: <1437030643-19731-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel.Elior@qlogic.com, netdev@vger.kernel.org,
	linux-firmware@kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58679 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbGPPUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 11:20:12 -0400
Content-Disposition: inline
In-Reply-To: <1437030643-19731-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 10:10:43AM +0300, Yuval Mintz wrote:
> The new FW will allow us to utilize some new features in our driver,
> mainly adding vlan stripping offload and vxlan offload support.
> 
> In addition, this fixes several issues:
>  - Packets from a VF with pvid configured which were sent with a
>    different vlan were transmitted instead of being discarded.
> 
>  - FCoE traffic might not recover after a failue while there's traffic
>    to another function.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> ---
> As mentioned, this was previously sent only to Ben/David.
> Now designating it to the proper mailing list.

applied.

regards, kyle
