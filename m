From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] bonding: export slave's
 actor_oper_port_state via sysfs and netlink
Date: Mon, 15 Jun 2015 10:09:38 -0400
Message-ID: <20150615140938.GF588@gospo.home.greyhouse.net>
References: <1434288995-25457-1-git-send-email-razor@blackwall.org>
 <1434288995-25457-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34894 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbFOOJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:09:33 -0400
Received: by qcsf5 with SMTP id f5so3708378qcs.2
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:09:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434288995-25457-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 14, 2015 at 04:36:34PM +0300, Nikolay Aleksandrov wrote:
> Export the actor_oper_port_state of each port via sysfs and netlink.
> In 802.3ad mode it is valuable for the user to be able to check the
> actor_oper state, it is already exported via bond's proc entry.
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_netlink.c     | 10 +++++++++-
>  drivers/net/bonding/bond_sysfs_slave.c | 16 ++++++++++++++++
>  include/uapi/linux/if_link.h           |  1 +
>  3 files changed, 26 insertions(+), 1 deletion(-)
