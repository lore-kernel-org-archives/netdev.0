From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:52:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929145246.6633187c.davem@davemloft.net>
References: <20040929214350.GA26714@wotan.suse.de>
	<Pine.NEB.4.33.0409291744500.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409291744500.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 17:51:22 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> I managed to get a tcpdump of one flow.  I accidentally deleted it, but
> from memory what I saw was it ramped up to large virtual segments, then
> got a partial ack for it (all but the last real segment -- delayed ack
> here) then later after the full ack got back sent one small segment.
> This segment was acked, but it never seemed to recognize this ack and
> repeatedly retransmitted it after timeouts.  (Generating the retrans_out
> leaked messages when the d-sacks came back.)
> 
> I can't conveniently get a backtrace of the crash right now.

I can get one now, thanks for the trace description it's
a good clue.
