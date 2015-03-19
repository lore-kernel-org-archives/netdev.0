From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] net: add support for phys_port_name
Date: Wed, 18 Mar 2015 22:30:50 -0400 (EDT)
Message-ID: <20150318.223050.836897753141133838.davem@davemloft.net>
References: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbbCSCaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:30:52 -0400
In-Reply-To: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 17 Mar 2015 20:23:15 -0600

> Similar to port id allow netdevices to specify port names and export
> the name via sysfs. Drivers can implement the netdevice operation to
> assist udev in having sane default names for the devices using the
> rule:
> 
> $ cat /etc/udev/rules.d/80-net-setup-link.rules
> SUBSYSTEM=="net", ACTION=="add", ATTR{phys_port_name}!="",
> NAME="$attr{phys_port_name}"
> 
> Use of phys_name versus phys_id was suggested-by Jiri Pirko.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Scott Feldman <sfeldma@gmail.com>

Applied to net-next.
