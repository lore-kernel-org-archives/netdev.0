From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "bridge: Allow forward delay to be cfgd when
 STP enabled"
Date: Tue, 10 Nov 2015 15:42:19 -0500 (EST)
Message-ID: <20151110.154219.28142723661620451.davem@davemloft.net>
References: <1447154132-13879-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbKJUmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 15:42:21 -0500
In-Reply-To: <1447154132-13879-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 10 Nov 2015 06:15:32 -0500

> This reverts commit 34c2d9fb0498c066afbe610b15e18995fd8be792.
> 
> There are 2 reasons for this revert:
>  1)  The commit in question doesn't do what it says it does.  The
>      description reads: "Allow bridge forward delay to be configured
>      when Spanning Tree is enabled."  This was already the case before
>      the commit was made.  What the commit actually do was disallow
>      invalid values or 'forward_delay' when STP was turned off.
> 
>  2)  The above change was actually a change in the user observed
>      behavior and broke things like libvirt and other network configs
>      that set 'forward_delay' to 0 without enabling STP.  The value
>      of 0 is actually used when STP is turned off to immediately mark
>      the bridge as forwarding.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Fair enough, applied, thanks Vlad.
