From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: batman-adv 2013-04-22
Date: Thu, 25 Apr 2013 01:33:53 -0400 (EDT)
Message-ID: <20130425.013353.779038075699652078.davem@davemloft.net>
References: <1366619894-16857-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3DYFdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:33:55 -0400
In-Reply-To: <1366619894-16857-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Mon, 22 Apr 2013 10:38:13 +0200

> here we have another (I think the last) fix intended for net/linux-3.9.
> 
> This patch fixes a bug in the Translation Table component. In particular, when
> batman-adv accesses the "inner Ethernet header", it has have to jump over its
> header which can have two different lengths. The current code assumes
> that this length is always the same and so leading to a wrong access.
> This patch fixes it by making the "jump" generic.
> 
> The bug is not very critical because it "only" breaks our "smart rerouting
> feature" and does not lead to a crash since the memory it accesses is always
> allocated. I would send it to stable, but you can decide whether it is worth or
> not.

Pulled, thanks.
