From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2 5/7] rhashtable: avoid
 unnecessary wakeup for worker queue
Date: Wed, 7 Jan 2015 18:28:42 +0800
Message-ID: <54AD0A5A.60207@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
	<1420609318-3261-6-git-send-email-ying.xue@windriver.com>
	<20150107095013.GJ21820@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20150107095013.GJ21820@casper.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/07/2015 05:50 PM, Thomas Graf wrote:
> On 01/07/15 at 01:41pm, Ying Xue wrote:
>> Move condition statements of verifying whether hash table size exceeds
>> its maximum threshold or reaches its minimum threshold from resizing
>> functions to resizing decision functions, avoiding unnecessary wakeup
>> for worker queue thread.
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Cc: Thomas Graf <tgraf@suug.ch>
> 
> Good optimization, thanks!
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>
> 
> Can you do a follow-up patch and add a note in rhashtable.h to
> indicate the implementation of the grow and shrink decision function
> must enforce min/max shift?
> 
> 

Thanks for the reminder, and I will do this later.

Regards,
Ying


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
