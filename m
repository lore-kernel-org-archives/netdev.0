From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Convert uses of typedef ctl_table to
 struct ctl_table
Date: Thu, 13 Jun 2013 02:36:34 -0700 (PDT)
Message-ID: <20130613.023634.1372572014231224544.davem@davemloft.net>
References: <0cd3f2ac0e85c8ff68dd2c67057a5d40aaec8337.1371016392.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758254Ab3FMJgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:36:35 -0400
In-Reply-To: <0cd3f2ac0e85c8ff68dd2c67057a5d40aaec8337.1371016392.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Jun 2013 23:04:25 -0700

> Reduce the uses of this unnecessary typedef.
> 
> Done via perl script:
> 
> $ git grep --name-only -w ctl_table net | \
>   xargs perl -p -i -e '\
> 	sub trim { my ($local) = @_; $local =~ s/(^\s+|\s+$)//g; return $local; } \
>         s/\b(?<!struct\s)ctl_table\b(\s*\*\s*|\s+\w+)/"struct ctl_table " . trim($1)/ge'
> 
> Reflow the modified lines that now exceed 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
