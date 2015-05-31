From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: unconditionally put
 sock refcnt when sock timer to be deleted is pending
Date: Sat, 30 May 2015 18:09:00 -0700 (PDT)
Message-ID: <20150530.180900.1737461837131789193.davem@davemloft.net>
References: <1432790362-19707-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1432790362-19707-1-git-send-email-ying.xue@windriver.com>
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
Date: Thu, 28 May 2015 13:19:22 +0800

> As sock refcnt is taken when sock timer is started in
> sk_reset_timer(), the sock refcnt should be put when sock timer
> to be deleted is in pending state no matter what "probing_state"
> value of tipc sock is.
> 
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.

------------------------------------------------------------------------------
