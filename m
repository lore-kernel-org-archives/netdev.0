From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 0/5] tipc: align TIPC
 behaviours of waiting for events with other stacks
Date: Fri, 17 Jan 2014 03:20:33 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C1C32E2@eusaamb103.ericsson.se>
References: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
	<20140116.191140.184722722665650663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Paul.Gortmaker@windriver.com" <Paul.Gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, "ying.xue@windriver.com"
	<ying.xue@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20140116.191140.184722722665650663.davem@davemloft.net>
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

Nice job, Ying.
///jon

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: January-16-14 10:12 PM
> To: ying.xue@windriver.com
> Cc: Paul.Gortmaker@windriver.com; maloy@donjonn.com; Jon Maloy; Erik
> Hugne; netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH net-next 0/5] tipc: align TIPC behaviours of waiting for
> events with other stacks
> 
> From: Ying Xue <ying.xue@windriver.com>
> Date: Fri, 17 Jan 2014 09:50:02 +0800
> 
> > Comparing the current implementations of waiting for events in TIPC
> > socket layer with other stacks, TIPC's behaviour is very different
> > because wait_event_interruptible_timeout()/wait_event_interruptible()
> > are always used by TIPC to wait for events while relevant socket or
> > port variables are fed to them as their arguments. As socket lock has
> > to be released temporarily before the two routines of waiting for
> > events are called, their arguments associated with socket or port
> > structures are out of socket lock protection. This might cause serious
> > issues where the process of calling socket syscall such as sendsmg(),
> > connect(), accept(), and recvmsg(), cannot be waken up at all even if
> > proper event arrives or improperly be woken up although the condition
> > of waking up the process is not satisfied in practice.
> >
> > Therefore, aligning its behaviours with similar functions implemented
> > in other stacks, for instance, sk_stream_wait_connect() and
> > inet_csk_wait_for_connect() etc, can avoid above risks for us.
> 
> Series applied, thank you.

------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
