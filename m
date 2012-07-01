From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Sun, 01 Jul 2012 10:31:12 -0700
Message-ID: <1341163872.2032.29.camel@joe2Laptop>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	 <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	 <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
	 <1341160685.2032.15.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36362 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750864Ab2GARbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 13:31:13 -0400
In-Reply-To: <1341160685.2032.15.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 09:38 -0700, Joe Perches wrote:

> I think this macro is suboptimal because
> negated names are easy to misuse.
> 
> I think type is also unnecessary and too
> easy to mismatch or keep up to date with
> field type changes.
> 
> Perhaps it's better as:
> 
> #define all_zeros_or_all_ones(field)		\
> ({						\
> 	field && (typeof(field))~field;		\
> })

Umm, or not.

It helps when I actually test the code not just type
it into an email client.

	!(field && (typeof(field))~field)
