From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on vlan
 device.
Date: Wed, 26 Mar 2014 21:15:05 +0000
Message-ID: <20140326211504.GA21393@macbook.localnet>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>
 <1395865711-3347-1-git-send-email-vyasevic@redhat.com>
 <20140326.171038.2150319831233512825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38003 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755425AbaCZVPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:15:13 -0400
Content-Disposition: inline
In-Reply-To: <20140326.171038.2150319831233512825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 05:10:38PM -0400, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Wed, 26 Mar 2014 16:28:31 -0400
> 
> > Some drivers incorrectly assign vlan acceleration features to
> > vlan_features thus causing issues for Q-in-Q vlan configurations.
> > Prevent this once and for all by masking off acceleration features
> > for vlan devices until such time as we support stacked acceleration.
> > 
> > Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> So what if we do have chips that can offload Q-in-Q?  Will we use
> a new flag?

For 802.1ad that was the intention, using the NETIF_F_HW_VLAN_STAG_* flags.
