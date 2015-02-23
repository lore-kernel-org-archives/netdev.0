From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] rhashtable: initialize all rhashtable walker
 members
Date: Mon, 23 Feb 2015 15:23:54 -0500 (EST)
Message-ID: <20150223.152354.942772703063232174.davem@davemloft.net>
References: <1424684106-5405-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424684106-5405-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Mon, 23 Feb 2015 04:35:06 -0500

> Commit f2dba9c6ff ("rhashtable: Introduce rhashtable_walk_*") forgot to
> initialize the members of struct rhashtable_walker after allocating it, which
> caused an undefined value for 'resize' which is used later on.
> 
> Fixes: f2dba9c6ff ("rhashtable: Introduce rhashtable_walk_*")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
