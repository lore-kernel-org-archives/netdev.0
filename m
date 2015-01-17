From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters - v2
Date: Sat, 17 Jan 2015 09:29:03 +0100
Message-ID: <20150117082903.GA1891@nanopsycho.orion>
References: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:32926 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbAQI3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 03:29:06 -0500
Received: by mail-we0-f174.google.com with SMTP id k48so23773175wev.5
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 00:29:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 16, 2015 at 10:22:29PM CET, dsahern@gmail.com wrote:
>Add packet and byte counters for RX and TX paths.
>
>$ ifconfig eth1
>eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>        inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
>        ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>        RX packets 63  bytes 15813 (15.4 KiB)
>        RX errors 1  dropped 0  overruns 0  frame 0
>        TX packets 79  bytes 17991 (17.5 KiB)
>        TX errors 7  dropped 0 overruns 0  carrier 0  collisions 0
>
>Rx / Tx errors tested by injecting faults in qemu's hardware model for Rocker.
>
>v2:
>- moved counter locations to avoid potential use after free per Florian's comment
>
>Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks David.
