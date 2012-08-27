From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues (VMDQ)
Date: Mon, 27 Aug 2012 12:47:18 +0300
Message-ID: <CAJZOPZJyXnHymw4D4VWAajc7Q1EeSaTHRYn7p9sKG2hiHGjr_A@mail.gmail.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1>
	<CAJZOPZJBhDdQp2-8WG-UsToPHwyawYYVctqjZMT8JN85DK3XYQ@mail.gmail.com>
	<503A7462.1030803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, shlomop@mellanox.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36672 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H0JrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 05:47:19 -0400
Received: by ialo24 with SMTP id o24so7752805ial.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 02:47:18 -0700 (PDT)
In-Reply-To: <503A7462.1030803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 26, 2012 at 10:09 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> That seems reasonable to me. Adding a 'sub' argument to the set
> routines should do it. Also the 'get' routines would need to be
> extended to report back these virtual net devices.
>
> int (*ndo_set_vf_mac)(struct net_device *dev, int vf, int sub, u8* mac);
> int (*ndo_set_vf_vlan)(struct net_device *dev,
>                        int vf, int sub, u16 vlan, u8 qos);
> int (*ndo_set_vf_tx_rate)(struct net_device *dev,
>                           int vf, int sub, int rate);
> int (*ndo_set_vf_spoofchk)(struct net_device *dev,
>                            int vf, int sub, bool setting);
> int (*ndo_get_vf_config)(struct net_device *dev,
>                          int vf, int sub,
>                          struct fila_vf_info *ivf)

> I would need to check if any of the ixgbe/igb supported hardware can
> support virtual device queues on virtual functions like this but I
> presume if your looking at this you have some hardware that can.

Yes, we look on HW that can.

Your suggestion makes sense, I will check here if this well addresses
the eswitch
use case we envision or/what is missing.

Or.
