From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netns: fix unbalanced spin_lock on error
Date: Thu, 14 May 2015 22:36:46 -0400 (EDT)
Message-ID: <20150514.223646.1372201078149333495.davem@davemloft.net>
References: <55533771.6080406@6wind.com>
	<1431517389-19937-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1431517389-19937-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 13 May 2015 13:43:09 +0200

> Unlock was missing on error path.
> 
> Fixes: 95f38411df05 ("netns: use a spin_lock to protect nsid management")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
