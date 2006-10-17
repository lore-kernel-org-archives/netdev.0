From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/13] [IPV6] Clean up BACKTRACK().
Date: Mon, 16 Oct 2006 22:11:46 -0700 (PDT)
Message-ID: <20061016.221146.66060975.davem@davemloft.net>
References: <45341E83.7010409@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1750
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423089AbWJQFLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:11:47 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <45341E83.7010409@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 03:06:27 +0300

> The fn check is unnecessary as fn can never be NULL in BACKTRACK().
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Applied, especially valid since we're walking parents up to
the, we break out at hitting root, and root's parent is
itself :-)

Thanks.
