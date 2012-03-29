From: Glauber Costa <glommer@parallels.com>
Subject: Re: [BUGFIX][PATCH 3/3] memcg/tcp: ignore tcp usage before accounting
 started
Date: Thu, 29 Mar 2012 11:21:07 +0200
Message-ID: <4F742983.1080402@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:48189 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839Ab2C2JVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 05:21:12 -0400
In-Reply-To: <4F740AEF.7090900@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 09:10 AM, KAMEZAWA Hiroyuki wrote:
> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
> starts before setting res->limit, there are already used resource.
> After setting res->limit, the resource (already used) will be uncharged and
> make res_counter below 0 because they are not charged. This causes warning.
> 
> This patch fixes that by adding res_counter_uncharge_nowarn().
> (*) We cannot avoid this while we have 'account start' switch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>

Fine by me.

Acked-by: Glauber Costa <glommer@parallels.com>
