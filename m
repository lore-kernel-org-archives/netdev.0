From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/8] switchdev: add IPv4 routing offload
Date: Fri, 06 Mar 2015 00:27:25 -0500 (EST)
Message-ID: <20150306.002725.2246917689017515390.davem@davemloft.net>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbbCFF11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:27:27 -0500
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu,  5 Mar 2015 21:21:12 -0800

> v4:
> 
>   - Add NETIF_F_NETNS_LOCAL to rocker port feature list to keep rocker
>     ports in the default netns.  Rocker hardware can't be partitioned
>     to support multiple namespaces, currently.  It would be interesting
>     to add netns support to rocker device by basically adding another
>     match field to each table to match on some unique netns ID, with
>     a port knowing it's netns ID.  Future work TDB.
>   - Up-level the RTNH_F_EXTERNAL marking of routes installed to offload
>     device from driver to switchdev common code.  Now driver can't skip
>     routes.  Either it can install the route or it cannot.  Yes or No.
>     If no on any route, all offloading is aborted by removing routes
>     from offload device and setting ipv4.fib_offload_disabled so no more
>     routes can be offloaded.  This is harsh, but it's our starting point.
>     We can refine the policies in follow-up work.
>   - Add new net.ipv4.fib_offload_disabled bool that is set if anything
>     goes wrong with route offloading.  We can refine this later to make
>     the setting per-device or per-device-port-netdev, but let's start
>     here simple and refine in follow-up work.
>   - Rebase against Alex's latest FIB changes.  I think I did everything
>     correctly, and didn't run into any issues with testing, but I'd like
>     Alex to look over the changes and maybe follow-up with any cleanups.

Looks great, series applied, thanks!
