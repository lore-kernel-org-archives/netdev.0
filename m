From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] ipv6: recreate ipv6 link-local addresses
 when increasing MTU over IPV6_MIN_MTU
Date: Fri, 30 Oct 2015 18:11:38 +0900 (KST)
Message-ID: <20151030.181138.814315883298269050.davem@davemloft.net>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
	<20151026180633.4289.4117.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758333AbbJ3JLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 05:11:40 -0400
In-Reply-To: <20151026180633.4289.4117.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 26 Oct 2015 11:06:33 -0700

> This change makes it so that we reinitialize the interface if the MTU is
> increased back above IPV6_MIN_MTU and the interface is up.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks.
