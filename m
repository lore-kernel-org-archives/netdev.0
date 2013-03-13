From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] ipv4: fix definition of FIB_TABLE_HASHSZ
Date: Wed, 13 Mar 2013 11:01:36 -0400 (EDT)
Message-ID: <20130313.110136.690489547299044594.davem@davemloft.net>
References: <1363170255-11769-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tingw.liu@gmail.com, kuznet@ms2.inr.ac.ru
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932759Ab3CMPBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:01:24 -0400
In-Reply-To: <1363170255-11769-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 13 Mar 2013 14:24:15 +0400

> From: "Denis V. Lunev" <den@openvz.org>
> 
> a long time ago by the commit
> 
>   commit 93456b6d7753def8760b423ac6b986eb9d5a4a95
>   Author: Denis V. Lunev <den@openvz.org>
>   Date:   Thu Jan 10 03:23:38 2008 -0800
> 
>     [IPV4]: Unify access to the routing tables.
> 
> the defenition of FIB_HASH_TABLE size has obtained wrong dependency:
> it should depend upon CONFIG_IP_MULTIPLE_TABLES (as was in the original
> code) but it was depended from CONFIG_IP_ROUTE_MULTIPATH
> 
> This patch returns the situation to the original state.
> 
> The problem was spotted by Tingwei Liu.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
