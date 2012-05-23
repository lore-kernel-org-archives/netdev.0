From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 00/17] netfilter: add namespace support for
 netfilter protos
Date: Wed, 23 May 2012 12:42:31 +0200
Message-ID: <20120523104231.GG2836@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41904 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758309Ab2EWKnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 06:43:12 -0400
Content-Disposition: inline
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 04:52:10PM +0800, Gao feng wrote:
> Currently the sysctl of netfilter proto is not isolated, so when
> changing proto's sysctl in container will cause the host's sysctl
> be changed too. it's not expected.
> 
> This patch set adds the namespace support for netfilter protos.
> 
> impletement four pernet_operations to register sysctl and initial
> pernet data for proto.
> 
> -ipv4_net_ops is used to register tcp4(compat),
>  udp4(compat),icmp(compat),ipv4(compat).
> -ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
> -sctp_net_ops is used to register sctp4(compat) and sctp6.
> -udplite_net_ops is used to register udplite4 and udplite6
> 
> extern l[3,4]proto (sysctl) register functions to make them support
> namespace.
> 
> finailly add namespace support for cttimeout.

This requires another spin. It looks way better than previous version
but I don't want to take the patchset and then send another batch to
David to remove the .compat field, the unrequired export of couple of
symbols, and so on...

Thanks!
