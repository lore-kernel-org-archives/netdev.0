From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3] deinline a few large functions in vlan code - v3
Date: Tue, 11 Apr 2006 01:36:42 -0700 (PDT)
Message-ID: <20060411.013642.78129957.davem@davemloft.net>
References: <200604111047.36941.vda@ilport.com.ua>
	<20060411.005858.49205474.davem@davemloft.net>
	<200604111111.12554.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: vda@ilport.com.ua
In-Reply-To: <200604111111.12554.vda@ilport.com.ua>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Vlasenko <vda@ilport.com.ua>
Date: Tue, 11 Apr 2006 11:11:12 +0300

> Ok, one last try. Would you like this smallish patch instead?
> It takes care of those BIG inlines.

You're putting vlan stuff into a net/core/*.c file, that
is not correct.

If we're not going to do the ifdef mess, fudging around it
by putting a "VLAN" function into generic networking core
code isn't the way to try and deal with it.

Like I said, let's just leave things they way they are.
Every suggestion shown so far has been worse than what we
have now.
