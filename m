From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN
Date: Wed, 29 Jul 2015 23:03:38 -0700 (PDT)
Message-ID: <20150729.230338.291206259590958006.davem@davemloft.net>
References: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com,
	nicolas.dichtel@6wind.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3GDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:03:39 -0400
In-Reply-To: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 29 Jul 2015 13:52:06 +0200

> This readds the config option CONFIG_OPENVSWITCH_VXLAN to avoid a
> hard dependency of OVS on VXLAN. It moves the VXLAN config compat
> code to vport-vxlan.c and allows compliation as a module.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Fixes: 2661371ace96 ("openvswitch: fix compilation when vxlan is a module")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
