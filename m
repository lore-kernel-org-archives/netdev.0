From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: tipc: fix information leak
	to userland
Date: Tue, 09 Nov 2010 09:26:30 -0800 (PST)
Message-ID: <20101109.092630.260076036.davem@davemloft.net>
References: <1288545032-16481-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, allan.stephens@windriver.com
To: segooon@gmail.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1288545032-16481-1-git-send-email-segooon@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segooon@gmail.com>
Date: Sun, 31 Oct 2010 20:10:32 +0300

> Structure sockaddr_tipc is copied to userland with padding bytes after
> "id" field in union field "name" unitialized.  It leads to leaking of
> contents of kernel stack memory.  We have to initialize them to zero.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Applied.

Patches #1 and #2 were given feedback which I need you to integrate
and submit new patches based upon, thanks.

------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
