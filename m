From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/1] dev: add per net_device packet type
 chains
Date: Thu, 29 Jan 2015 14:42:03 -0800 (PST)
Message-ID: <20150129.144203.302733822459817977.davem@davemloft.net>
References: <1422387348-10885-1-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, therbert@google.com, jiri@resnulli.us,
	vyasevic@redhat.com, netdev@vger.kernel.org, ebiederm@xmission.com
To: noureddine@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbbA2WmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:42:04 -0500
In-Reply-To: <1422387348-10885-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@arista.com>
Date: Tue, 27 Jan 2015 11:35:48 -0800

> When many pf_packet listeners are created on a lot of interfaces the
> current implementation using global packet type lists scales poorly.
> This patch adds per net_device packet type lists to fix this problem.
> 
> The patch was originally written by Eric Biederman for linux-2.6.29.
> Tested on linux-3.16.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Salam Noureddine <noureddine@arista.com>

This looks fine, applied, thanks.
