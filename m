From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Sun, 15 Aug 2004 23:27:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815232754.2464e731.davem@redhat.com>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
	<20040812124854.646f1936.davem@redhat.com>
	<20040813115140.0f09d889@dell_ss3.pdx.osdl.net>
	<20040813212857.7dd50320.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, alan@lxorguk.ukuu.org.uk, tytso@mit.edu,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040813212857.7dd50320.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Aug 2004 21:28:57 +0200
Andi Kleen <ak@suse.de> wrote:

> On Fri, 13 Aug 2004 11:51:40 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Here is another alternative, using tansworthe generator.  It uses percpu
> > state. The one small semantic change is the net_srandom() only affects
> > the current cpu's seed.  The problem was that having it change all cpu's
> > seed would mean adding locking 
> 
> I would just update the other CPUs without locking. Taking
> a random number from a partially updated state shouldn't be a big 
> issue.

I personally don't think we need to touch the other cpus
at all, and that having a different current seed on each
cpu might actually be a good thing.

Stephen, I like this one a lot, especially compared to
what we had before.  I'm going to add this to my tree for
the time being.
