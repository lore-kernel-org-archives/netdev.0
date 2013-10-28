From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] tipc: message reassembly
 using fragment chain
Date: Mon, 28 Oct 2013 01:07:37 -0400 (EDT)
Message-ID: <20131028.010737.400887499395331496.davem@davemloft.net>
References: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
	<1382812863-23571-3-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1382812863-23571-3-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sat, 26 Oct 2013 14:41:02 -0400

> +			int ret = tipc_link_recv_fragment(
> +					&node->bclink.reasm_head,
> +					&node->bclink.reasm_tail,
> +					&buf);

This is not the correct way to indent a function call that spans
multiple lines.  In such a situation the arguments that appear
on the second and subsequent lines must start at the first column
after the openning parenthesis of the function call.

Like this:

	func(a, b, c,
	     d, e, f);

Please audit this in your entire set of patches and resubmit,
thanks.

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
