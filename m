From: "David S. Miller" <davem@redhat.com>
Subject: Re: 6to4/SIT and IP DF
Date: Wed, 15 Oct 2003 22:27:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015222712.18d1434f.davem@redhat.com>
References: <OF32DA07F2.CE83636D-ON88256DC1.001CC44C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, r.venning@telstra.com, nate@thebog.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF32DA07F2.CE83636D-ON88256DC1.001CC44C@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 22:21:37 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> That doesn't sound terrible, but won't it have to drop a minimum of
> 2 packets per tunnel on an MTU change (or initial probe with a large
> packet)?

Welcome to the real world where most routers don't quote enough
information.  :) What we do is the only sane way to handle this
problem.

All of our ipv4 tunnels work this way due to that quoting size issue.

The "fragment but tell me about it" isn't such a great idea.  You'll
run into all kinds of difficult decisions about behavior in the cases
where a too-big packet overruns multiple hops on the path.  This is why
the original implementors didn't put this into the RFCs.
