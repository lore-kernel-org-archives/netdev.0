From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] vxlan: remove vxlan_group_used in
 vxlan_open
Date: Wed, 11 Dec 2013 14:21:48 -0500 (EST)
Message-ID: <20131211.142148.664536514880152410.davem@davemloft.net>
References: <1386664653-27082-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab3LKTVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:21:50 -0500
In-Reply-To: <1386664653-27082-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 10 Dec 2013 16:37:32 +0800

> In vxlan_open, vxlan_group_used always returns true,
> because the state of the vxlan deivces which we want
> to open has alreay been running. and it has already
> in vxlan_list.
> 
> Since ip_mc_join_group takes care of the reference
> of struct ip_mc_list. removing vxlan_group_used here
> is safe.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
