From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: 2013-10-02
Date: Thu, 03 Oct 2013 15:58:02 -0400 (EDT)
Message-ID: <20131003.155802.929707046474176566.davem@davemloft.net>
References: <1380744201-2074-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754919Ab3JCT6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:58:04 -0400
In-Reply-To: <1380744201-2074-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed,  2 Oct 2013 22:03:20 +0200

> this is a "one-change" pull request intended for net/linux-3.{12,11,10}.
> 
> This patch from Matthias Schiffer is fixing the init routine of the Network
> Coding component by preventing it from registering the handler for the CODED
> packet type each time a new soft-interface is created.
> 
> Without this fix a second soft-interface cannot be created unless the Network
> Coding component is not part of the module (not compiled-in).
> 
> As I mentioned before, this fix should be queued for stable as it aims
> kernels older than linux-3.12.
> 
> Please pull or let me know of any problem.

Pulled, thanks Antonio.
