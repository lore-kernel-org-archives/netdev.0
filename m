From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 0/8] tipc: some cleanups and
	improvements
Date: Fri, 20 Nov 2015 20:18:20 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D2238A602@eusaamb103.ericsson.se>
References: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
	<20151120.140657.2023428662451748232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "parthasarathy.xx.bhuvaragan@ericsson.com"
	<parthasarathy.xx.bhuvaragan@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20151120.140657.2023428662451748232.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, 20 November, 2015 14:07
> To: Jon Maloy
> Cc: netdev@vger.kernel.org; paul.gortmaker@windriver.com;
> parthasarathy.xx.bhuvaragan@ericsson.com; Richard Alpe; Ying Xue;
> maloy@donjonn.com; tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH net-next 0/8] tipc: some cleanups and improvements
> 
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Thu, 19 Nov 2015 14:30:38 -0500
> 
> > This series mostly contains cleanups and cosmetic code changes.
> > The only real functional change is in #4 and #5, where we change the
> > locking structure for nodes and links in order to permit full
> > concurrency between links working in parallel on different interfaces.
> > Since the groundwork for this has been done in previous commit series,
> > this change constitutes only the final, small step to achieve that goal.
> 
> Series applied, thanks.
> 
> Generally speaking, rwlock usage really never buys you anything significant.
> Therefore in the long run I think a single spinlock plus RCU is going to be
> much better for per-node locking in TIPC.

Thank you for the feedback.  My own benchmarking has already confirmed
what you are stating.  I am currently looking at how to convert it to RCU.

///jon


------------------------------------------------------------------------------
