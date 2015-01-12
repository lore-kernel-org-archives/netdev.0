From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] bridge: support for vlan range in
 setlink/dellink
Date: Mon, 12 Jan 2015 16:47:39 -0500 (EST)
Message-ID: <20150112.164739.1760377618648041119.davem@davemloft.net>
References: <1420903874-25528-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbALVrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:47:42 -0500
In-Reply-To: <1420903874-25528-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Sat, 10 Jan 2015 07:31:11 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This series adds new flags in IFLA_BRIDGE_VLAN_INFO to indicate
> vlan range.
> 
> Will post corresponding iproute2 patches if these get accepted.
> 
> v1-> v2
>     - changed patches to use a nested list attribute
>     IFLA_BRIDGE_VLAN_INFO_LIST as suggested by scott feldman
>     - dropped notification changes from the series. Will post them
>     separately after this range message is accepted.
> 
> v2 -> v3
>     - incorporated some review feedback
>     - include patches to fill vlan ranges during getlink
>     - Dropped IFLA_BRIDGE_VLAN_INFO_LIST. I think it may get
>     confusing to userspace if we introduce yet another way to
>     send lists. With getlink already sending nested
>     IFLA_BRIDGE_VLAN_INFO in IFLA_AF_SPEC, It seems better to
>     use the existing format for lists and just use the flags from v2
>     to mark vlan ranges
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

This looks fine to me, series applied, thanks.
