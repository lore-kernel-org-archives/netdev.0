From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: unify the pcpu_tstats and
 br_cpu_netstats as one
Date: Sat, 04 Jan 2014 20:12:06 -0500 (EST)
Message-ID: <20140104.201206.1001436444725716496.davem@davemloft.net>
References: <1388815080-5408-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	stephen@networkplumber.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbaAEBMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:12:07 -0500
In-Reply-To: <1388815080-5408-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat,  4 Jan 2014 13:57:59 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> They are same, so unify them as one, pcpu_sw_netstats.
> 
> Define pcpu_sw_netstat in netdevice.h, remove pcpu_tstats
> from if_tunnel and remove br_cpu_netstats from br_private.h
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
