From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] Involve
 rhashtable_lookup_insert routine
Date: Thu, 08 Jan 2015 19:48:16 -0800 (PST)
Message-ID: <20150108.194816.427378965781678590.davem@davemloft.net>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, tgraf@suug.ch
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
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
Date: Wed, 7 Jan 2015 13:41:51 +0800

> The series aims to involve rhashtable_lookup_insert() to guarantee
> that the process of lookup and insertion of an object from/into hash
> table is finished atomically, allowing rhashtable's users not to
> introduce an extra lock during search and insertion. For example,
> tipc socket is the first user benefiting from this enhancement. 

Looks good, series applied.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
