From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: fix potential NULL pointer dereference
Date: Tue, 13 May 2014 00:27:48 -0400 (EDT)
Message-ID: <20140513.002748.1953485391009395590.davem@davemloft.net>
References: <1399660892-19008-1-git-send-email-susant@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: susant@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaEME1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:27:50 -0400
In-Reply-To: <1399660892-19008-1-git-send-email-susant@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Susant Sahani <susant@redhat.com>
Date: Sat, 10 May 2014 00:11:32 +0530

> The function ip6_tnl_validate assumes that the rtnl
> attribute IFLA_IPTUN_PROTO always be filled . If this
> attribute is not filled by  the userspace application
> kernel get crashed with NULL pointer dereference. This
> patch fixes the potential kernel crash when
> IFLA_IPTUN_PROTO is missing .
> 
> Signed-off-by: Susant Sahani <susant@redhat.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable, thanks.
