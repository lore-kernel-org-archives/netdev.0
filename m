From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: fix error handling of expanding
	buffer headroom
Date: Tue, 24 Nov 2015 13:33:16 +0800
Message-ID: <5653F69C.4060406@windriver.com>
References: <1448177919-8646-1-git-send-email-ying.xue@windriver.com>
	<20151123.233547.446739112661995737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, stephen@networkplumber.org,
	tipc-discussion@lists.sourceforge.net, scan-admin@coverity.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20151123.233547.446739112661995737.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11/24/2015 12:35 PM, David Miller wrote:
> pskb_expand_head() returns negative error codes, therefore zero means
> success and therefore this "!err" check is reversed.

Thank you for pointing out such a stupid mistake I made.

I will send v2 to correct it.

Regards,
Ying


------------------------------------------------------------------------------
Go from Idea to Many App Stores Faster with Intel(R) XDK
Give your users amazing mobile app experiences with Intel(R) XDK.
Use one codebase in this all-in-one HTML5 development environment.
Design, debug & build mobile apps & 2D/3D high-impact games for multiple OSs.
http://pubads.g.doubleclick.net/gampad/clk?id=254741551&iu=/4140
