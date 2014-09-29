From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: add source mode
Date: Mon, 29 Sep 2014 15:36:53 -0400 (EDT)
Message-ID: <20140929.153653.1684891612078458544.davem@davemloft.net>
References: <1411655468-485-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de
To: michael-dev@fami-braun.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaI2Tg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:36:56 -0400
In-Reply-To: <1411655468-485-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: michael-dev@fami-braun.de
Date: Thu, 25 Sep 2014 16:31:08 +0200

> From: Michael Braun <michael-dev@fami-braun.de>
> 
> This patch adds a new mode of operation to macvlan, called "source".
> It allows one to set a list of allowed mac address, which is used
> to match against source mac address from received frames on underlying
> interface.
> This enables creating mac based VLAN associations, instead of standard
> port or tag based. The feature is useful to deploy 802.1x mac based
> behavior, where drivers of underlying interfaces doesn't allows that.
> 
> Configuration is done through the netlink interface using e.g.:
>  ip link add link eth0 name macvlan0 type macvlan mode source
>  ip link add link eth0 name macvlan1 type macvlan mode source
>  ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>  ip link set link dev macvlan0 type macvlan macaddr add 00:22:22:22:22:22
>  ip link set link dev macvlan0 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link dev macvlan1 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link dev macvlan1 type macvlan macaddr add 00:44:44:44:44:44
> 
> This allows clients with MAC addresses 00:11:11:11:11:11,
> 00:22:22:22:22:22 to be part of only VLAN associated with macvlan0
> interface. Clients with MAC addresses 00:44:44:44:44:44 with only VLAN
> associated with macvlan1 interface. And client with MAC address
> 00:33:33:33:33:33 to be associated with both VLANs.
> 
> Based on work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

Applied, thanks.
