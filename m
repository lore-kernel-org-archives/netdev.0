From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: initialize all rhashtable walker members
Date: Sun, 22 Feb 2015 15:58:38 -0500 (EST)
Message-ID: <20150222.155838.307897095859530348.davem@davemloft.net>
References: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sat, 21 Feb 2015 15:55:11 -0500

> Commit "rhashtable: Introduce rhashtable_walk_*" forgot to initialize the
> members of struct rhashtable_walker after allocating it, which caused
> an undefined value for 'resize' which is used later on.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Commits should be referred to by SHA1 ID as well as the commit
header text (in parenthesis and double quotes).

Even better, refer to the commit using a "Fixes: " tag right before
your signoff.
