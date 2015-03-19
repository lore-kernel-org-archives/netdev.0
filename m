From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] rocker: add support for phys_port_name
Date: Wed, 18 Mar 2015 22:30:56 -0400 (EDT)
Message-ID: <20150318.223056.206466873437715947.davem@davemloft.net>
References: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
	<1426645397-15284-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbCSCa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:30:58 -0400
In-Reply-To: <1426645397-15284-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 17 Mar 2015 20:23:16 -0600

> Implement the phys_port_name operation. Port names are pulled from the
> rocker hardware model in qemu and default to the qemu name + port id.
> e.g.,
> 
> sw1p1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
>         ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>         RX packets 0  bytes 0 (0.0 B)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 0  bytes 0 (0.0 B)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> 
> where 'sw1' comes from the qemu command line -device rocker,name=sw1, and
> 'p1' is port 1.
> 
> Patch is adapted from Scott's phys_port_id patch.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Acked-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Applied to net-next.
