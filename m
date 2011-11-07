From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 13:44:01 -0800
Message-ID: <20111107134401.21cb3bf0@nehalam.linuxnetplumber.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
	<1320512055-1231037-2-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42924 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab1KGVoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 16:44:03 -0500
In-Reply-To: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2011 17:54:14 +0100
David Lamparter <equinox@diac24.net> wrote:

> +#define vlangrp_for_each_dev(i, grp, vlandev) \
> +	for (i = 0; i < VLAN_N_VID * VLAN_N_PROTOCOL; i++) \
> +		if ((vlandev = vlan_group_get_device_pidx(grp, \
> +					i / VLAN_N_VID, i % VLAN_N_VID)))
> +			/* { code here } */
> +

Please just open code this. Macro's make the code harder
to parse for humans. There are a few exceptions like.
  LIST_FOREACH_RCU()
