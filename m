From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/2] af_mpls: fix undefined reference to
 ip6_route_output with CONFIG_IPV6=n
Date: Fri, 31 Jul 2015 15:21:47 -0700 (PDT)
Message-ID: <20150731.152147.1257102811012321911.davem@davemloft.net>
References: <1438288494-32581-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hannes@stressinduktion.org, rshearma@brocade.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jon.maloy@ericsson.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbbGaWVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:21:48 -0400
In-Reply-To: <1438288494-32581-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu, 30 Jul 2015 13:34:52 -0700

> This patch series uses ipv6_stub_impl.ipv6_dst_lookup instead of 
> ip6_route_output. Follows the vxlan drivers usage of
> ipv6_stub_impl.ipv6_dst_lookup.
> 
> There is no sk in the af_mpls context from where
> ipv6_stub_impl.ipv6_dst_lookup is used. sk appears to be needed
> to get the namespace 'net' and is optional otherwise. This patch series
> changes ipv6_stub_impl.ipv6_dst_lookup to take net argument. sk remains
> optional.

Series applied, thanks.
