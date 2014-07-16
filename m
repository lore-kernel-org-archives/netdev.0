From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 3/7] tipc: add new functions
 for multicast and broadcast distribution
Date: Wed, 16 Jul 2014 22:21:04 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C289DE7@eusaamb103.ericsson.se>
References: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
	<1405446370-11781-4-git-send-email-jon.maloy@ericsson.com>
	<20140716.151050.974076735111970390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20140716.151050.974076735111970390.davem@davemloft.net>
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
> Sent: July-16-14 6:11 PM
> To: Jon Maloy
> Cc: netdev@vger.kernel.org; paul.gortmaker@windriver.com; Erik Hugne;
> ying.xue@windriver.com; maloy@donjonn.com; tipc-
> discussion@lists.sourceforge.net
> Subject: Re: [PATCH net-next 3/7] tipc: add new functions for multicast and
> broadcast distribution
> 
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Tue, 15 Jul 2014 13:46:06 -0400
> 
> > +	/* Copy header if single buffer */
> > +	if (!buf->next) {
> > +		hdr_sz = skb_headroom(buf) + msg_hdr_sz(buf_msg(buf));
> > +		head = __pskb_copy(buf, hdr_sz, GFP_ATOMIC);
> > +		if (likely(head))
> > +			return head;
> > +		return NULL;
> 
> These last four lines are simply:
> 
> 		return __pskb_copy(buf, hdr_sz, GFP_ATOMIC);
> 
> Don't make this code more complicated than necessary :)

Uhh...  Of course.  I think I changed this code back and forth too many times.
If that is all,  I'll post the series again asap.

///jon

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
