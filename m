From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label
Date: Thu, 24 May 2012 15:58:16 -0400
Message-ID: <20120524195816.GA6487@windriver.com>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
	<20120521.023926.548567931208958037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	allan.stephens@windriver.com, maloy@donjonn.com
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20120521.023926.548567931208958037.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

[Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label] On 21/05/2012 (Mon 02:39) David Miller wrote:

> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Mon, 21 May 2012 01:59:12 -0400
> 
> > With the latest series of patches from Paul Gortmaker and Allan
> > Stephens TIPC is now functionally mature and stable enough to
> > justify removal of the EXPERIMENTAL label.
> > 
> > Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> 
> I'll let Paul Gortmaker decide whether this is warranted or
> not.

The EXPERIMENTAL thing has always been rather subjective, but
I'd like to see some level of confidence that a crafted up bogus
TIPC message can't be used to DOS a machine with active TIPC
connections before removing EXPERIMENTAL.  Maybe the current code
is OK as-is in this respect but I'd feel better knowing that it
had been audited with this exact kind of thing in mind.

> 
> I don't really want to all of a sudden start seeing patches from
> people like you and the windriver folks, who effectively wrote off
> upstream and left poor Paul Gortmaker holding the bag and having to
> take care of EVERYTHING.

To be fair, I should note that Al did a lot of work in the background
getting commits onto a modern baseline and answering all my questions
since the out of tree sourceforge mess was highlighted here on netdev.

> 
> You can't just do nothing for years, end up making someone else
> do it, then say "Hey here I am, I feel like submitting upstream
> patches now" after I've spent this entire time starting to trust
> Paul for TIPC patches.

I've been thinking about this off and on, and I'm wondering what to
suggest going forward.  Dealing with the backlog was largely going over
maintenance and bugfix type patches and sanitizing them for integration
upstream.  It largely boiled down to being able to tell a crap patch
from a good one that matched upstream expectations.  I figured I could
manage to not screw that up too badly, hence why I volunteered to assist
with the backlog.

But for new TIPC development features, future direction, and things like
that -- making the right call requires intimate understanding of TIPC
and its users, which is something that a maintainer should have but
something I know I don't have.  (A man has to know his limitations.)

In this context, I'm not talking about these three trivial patches; but
more complicated stuff that I imagine will be floated in the future.

To that end, I can still review and call out issues in a crap patch when
I see them.  But I'd like to see new stuff sent to netdev, so that folks
smarter than me have a chance to catch when a patch appears generally OK
but is architecturally the wrong direction etc.

Paul.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
