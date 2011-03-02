From: Robert Love <robert.w.love@intel.com>
Subject: Re: [question] fcoe: bonding support
Date: Tue, 01 Mar 2011 16:05:11 -0800
Message-ID: <1299024311.24189.88.camel@fritz>
References: <20110228122957.GB4043@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:58188 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab1CBAFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 19:05:12 -0500
In-Reply-To: <20110228122957.GB4043@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 04:29 -0800, Jiri Pirko wrote:
> Hi Robert.
> 
Hi Jirka,

   I think the other community members have probably answered your
questions sufficiently, but since you addressed me directly I figured I
should reply. Let me know if you need any further assistance. I'll also
be happy to pick up your patch when it's done.

//Rob

> I wonder what's the meaning of the following code in fcoe_interface_setup():
> 
>         /* Do not support for bonding device */
>         if ((netdev->priv_flags & IFF_MASTER_ALB) ||
>             (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
>             (netdev->priv_flags & IFF_MASTER_8023AD)) {
>                 FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
>                 return -EOPNOTSUPP;
>         }
> 
> From this I cannot understand if bonding is not supported at all or
> only alb and 8023ad modes are not supported (leaving aside completely
> bogus checking for IFF_SLAVE_INACTIVE).
> 
> How about to check IFF_BONDING only (in case bonding should not be
> supported at all)
> 
> Thanks.
> 
> Jirka


