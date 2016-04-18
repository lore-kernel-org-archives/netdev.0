From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] fec: ethtool: move to new api
 {get|set}_link_ksettings
Date: Mon, 18 Apr 2016 14:45:26 -0400 (EDT)
Message-ID: <20160418.144526.1727838457143531009.davem@davemloft.net>
References: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: decot@googlers.com, f.fainelli@gmail.com, fugang.duan@nxp.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Apr 2016 00:34:58 +0200

> Ethtool has a new api {get|set}_link_ksettings that deprecate
> the old api {get|set}_settings. We update the fec driver to use
> this new ethtool api.
> 
> For this first version, I've converted old u32 value in phy structure
> to link_modes structure. Another way would be to replace u32 in
> phy structure to use DECLARE_LINK_MODE_MASK for advertising, ....

Series applied, thanks.
