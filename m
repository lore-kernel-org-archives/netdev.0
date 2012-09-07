From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Small bug on rxhash calculation
Date: Fri, 07 Sep 2012 12:57:48 -0400 (EDT)
Message-ID: <20120907.125748.25526531079163699.davem@davemloft.net>
References: <CAEb0MffEfboq_VmPFCtzGHe-SQ4Dd1O6Hptrc_jHVnp7itKyQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, chema@google.com
To: chema@berkeley.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab2IGQ5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 12:57:51 -0400
In-Reply-To: <CAEb0MffEfboq_VmPFCtzGHe-SQ4Dd1O6Hptrc_jHVnp7itKyQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@berkeley.edu>
Date: Wed, 5 Sep 2012 23:35:40 -0700

> -       if (keys.ports) {
> -               if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
> -                       swap(keys.port16[0], keys.port16[1]);
> +       if (keys.ports)

This patch was corrupted by your email client, it transformed TAB characters
into spaces, making your patch completely useless to us.

Please fix this, send a test patch to yourself, and make sure that the patch
you receive in that test email will apply cleanly and properly.

Only after you are able to get such an email test patch to work should
you submit it here again.

Thanks.
