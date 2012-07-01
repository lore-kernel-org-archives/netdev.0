From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Sun, 01 Jul 2012 12:52:32 -0700
Message-ID: <1341172352.8675.5.camel@joe2Laptop>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	 <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	 <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
	 <1341160685.2032.15.camel@joe2Laptop> <1341163872.2032.29.camel@joe2Laptop>
	 <m2ipe72u78.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.co.il>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32976 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756172Ab2GATwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 15:52:33 -0400
In-Reply-To: <m2ipe72u78.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 20:48 +0200, Andreas Schwab wrote:
> Joe Perches <joe@perches.com> writes:
> > On Sun, 2012-07-01 at 09:38 -0700, Joe Perches wrote:
> >> Perhaps it's better as:
> >> 
> >> #define all_zeros_or_all_ones(field)		\
> >> ({						\
> >> 	field && (typeof(field))~field;		\
> >> })
> >
> > Umm, or not.
> >
> > It helps when I actually test the code not just type
> > it into an email client.
> >
> > 	!(field && (typeof(field))~field)
> 
> Or write it as (!field || !(typeof(field))~field) which more closely
> resembles what the macro name expresses.

Better still, or maybe:

	field == 0 || field == (typeof field)~0
