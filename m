From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: print a notification on device rename
Date: Sun, 20 Jul 2014 20:44:39 -0700 (PDT)
Message-ID: <20140720.204439.469415924513948216.davem@davemloft.net>
References: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vyasevic@redhat.com,
	stephen@networkplumber.org, hkchu@google.com,
	bhutchings@solarflare.com, David.Laight@ACULAB.COM
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbaGUDok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:44:40 -0400
In-Reply-To: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 17 Jul 2014 20:33:32 +0200

> Currently it's done silently (from the kernel part), and thus it might be
> hard to track the renames from logs.
> 
> Add a simple netdev_info() to notify the rename, but only in case the
> previous name was valid.
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: stephen hemminger <stephen@networkplumber.org>
> CC: Jerry Chu <hkchu@google.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

This is fine, applied.
