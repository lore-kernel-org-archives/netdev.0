From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] add GENEVE netdev tunnel driver
Date: Wed, 13 May 2015 15:59:59 -0400 (EDT)
Message-ID: <20150513.155959.2157726077545160055.davem@davemloft.net>
References: <1431536250-14760-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, azhou@nicira.com,
	stephen@networkplumber.org, alexander.h.duyck@redhat.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030234AbbEMUAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:00:02 -0400
In-Reply-To: <1431536250-14760-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 13 May 2015 12:57:25 -0400

> This 5-patch kernel series adds a netdev implementation of a GENEVE
> tunnel driver, and the single iproute2 patch enables creation and
> such for those netdevs.  This makes use of the existing GENEVE
> infrastructure already used by the OVS code.  The net/ipv4/geneve.c
> file is renamed as net/ipv4/geneve_core.c as part of these changes.
 ...
> The overall structure of the GENEVE netdev driver is strongly
> influenced by the VXLAN netdev driver.  This is not surprising, as the
> two drivers are intended to serve similar purposes.  As development of
> the GENEVE driver continues, it is likely that those similarities will
> grow stronger.  This will include both simple configuration options
> (e.g. TOS and TTL settings) and new control plane support.
> 
> The current implementation is very simple, restricting itself to point
> to point links over IPv4.  This is due only to the simplicity of the
> implementation, and no such limit is inherent to GENEVE in any way.
> Support for IPv6 links and more sophisticated control plane options
> are predictable enhancements.
> 
> Using the included iproute2 patch, a GENEVE tunnel is created thusly:
> 
>         ip link add dev gnv0 type geneve remote 192.168.22.1 vni 1234
>         ip link set gnv0 up
>         ip addr add 10.1.1.1/24 dev gnv0
> 
> After a corresponding tunnel interface is created at the link partner,
> traffic should proceed as expected.
> 
> Please let me know if anyone has problems...thanks!

Looks good, series applied, thanks John!
