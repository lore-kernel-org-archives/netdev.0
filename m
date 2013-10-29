From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next] tipc: remove two indentation
 levels in tipc_recv_msg routine
Date: Tue, 29 Oct 2013 13:07:08 +0100
Message-ID: <20131029120708.GI14038@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 11:13:09AM +0000, David Laight wrote:
> I can only see one 'goto cont', an explicit kfree_skb() and
> continue would be clearer.

There's actually a few more 'goto cont' in the early error checks
in this function causes it to bail early. Those are not visible
in the patchdiff however.

//E

------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
