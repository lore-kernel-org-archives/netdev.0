From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [07/08] [TCP] Fix BIC congestion avoidance algorithm error
Date: Tue, 5 Apr 2005 14:22:02 -0400
Message-ID: <20050405182202.GA11979@thunk.org>
References: <20050405164539.GA17299@kroah.com> <20050405164758.GH17299@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, stable@kernel.org, davem@davemloft.net,
        shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <gregkh@suse.de>
Content-Disposition: inline
In-Reply-To: <20050405164758.GH17299@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2005 at 09:47:59AM -0700, Greg KH wrote:
> 
> -stable review patch.  If anyone has any objections, please let us know.
> 
> While redoing BIC for the split up version, I discovered that the
> existing 2.6.11 code doesn't really do binary search. It ends up
> being just a slightly modified version of Reno.  See attached graphs
> to see the effect over simulated 1mbit environment.

I hate to be a stickler for the rules, but does this really meet this
criteria?

 - It must fix a real bug that bothers people (not a, "This could be a
   problem..." type thing.)

If the congestion control alogirthm is "Reno-like", what is
user-visible impact to users?  There are OS's out there with TCP/IP
stacks that are still using Reno, aren't there?  

Knowing the answer to the question, "How does this bug `bother' either
users or network administrators?" would probably be really helpful.

						- Ted
