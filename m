From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: don't need to initialize instance_table
Date: Thu, 09 Dec 2010 11:56:48 -0800 (PST)
Message-ID: <20101209.115648.104053657.davem@davemloft.net>
References: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  9 Dec 2010 18:10:21 +0800

> Since instance_table is a static array, and has been zeroed already, we
> don't need to take CPU cycles to initialize it.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Adding a dependency on the implementation of HLISTs is not a good
idea, I would not apply this patch.
