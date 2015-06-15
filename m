From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] bonding: export slave's
 partner_oper_port_state via sysfs and netlink
Date: Mon, 15 Jun 2015 10:10:08 -0400
Message-ID: <20150615141008.GG588@gospo.home.greyhouse.net>
References: <1434288995-25457-1-git-send-email-razor@blackwall.org>
 <1434288995-25457-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36025 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbbFOOKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:10:02 -0400
Received: by qgal13 with SMTP id l13so5324456qga.3
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:10:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434288995-25457-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 14, 2015 at 04:36:35PM +0300, Nikolay Aleksandrov wrote:
> Export the partner_oper_port_state of each port via sysfs and netlink.
> In 802.3ad mode it is valuable for the user to be able to check the
> partner_oper state, it is already exported via bond's proc entry.
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> Note: There's one line that's > 80 chars, but it's an IFLA name and can't
>       be broken in a sane way.
> 
>  drivers/net/bonding/bond_netlink.c     |  5 +++++
>  drivers/net/bonding/bond_sysfs_slave.c | 16 ++++++++++++++++
>  include/uapi/linux/if_link.h           |  1 +
>  3 files changed, 22 insertions(+)
> 
