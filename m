From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix a possible memory
	leak
Date: Sun, 27 Apr 2014 19:08:37 -0400 (EDT)
Message-ID: <20140427.190837.707322541700403633.davem@davemloft.net>
References: <1398393855-24772-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, dan.carpenter@oracle.com
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398393855-24772-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 25 Apr 2014 10:44:15 +0800

> The commit a8b9b96e959f3c035af20b1bd2ba67b0b7269b19 ("tipc: fix race
> in disc create/delete") leads to the following static checker warning:
> 
> 	net/tipc/discover.c:352 tipc_disc_create()
> 		warn: possible memory leak of 'req'
> 
> The risk of memory leak really exists in practice. Especially when
> it's failed to allocate memory for "req->buf", tipc_disc_create()
> doesn't free its allocated memory, instead just directly returns
> with ENOMEM error code. In this situation, memory leak, of course,
> happens.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.

------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
