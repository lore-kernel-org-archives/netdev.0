From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix the incorrect return value of throw route
Date: Fri, 23 Oct 2015 02:38:47 -0700 (PDT)
Message-ID: <20151023.023847.1060924314321346995.davem@davemloft.net>
References: <13819cbd31a50ae677a94763be27e16118e90322.1445585813.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbJWJWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:22:17 -0400
In-Reply-To: <13819cbd31a50ae677a94763be27e16118e90322.1445585813.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 23 Oct 2015 15:36:53 +0800

> The error condition -EAGAIN, which is signaled by throw routes, tells
> the rules framework to walk on searching for next matches. If the walk
> ends and we stop walking the rules with the result of a throw route we
> have to translate the error conditions to -ENETUNREACH.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
