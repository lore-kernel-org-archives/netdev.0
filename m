From: kashyapv <kashyapv@us.ibm.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 11:30:32 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402251119060.3691-100000@dyn319495.beaverton.ibm.com>
References: <20040225111719.4b99403a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@osdl.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040225111719.4b99403a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004, David S. Miller wrote:

> On Wed, 25 Feb 2004 11:07:48 -0800 (PST)
> kashyapv <kashyapv@us.ibm.com> wrote:
> 
> > Also, an in-kernel solution allows administrative control and tuning 
> > without affecting the applications at all. The administrator can as per 
> > the policy (which may change over time) modify the proportions using another
> > interface. Otherwise, each application must provide a way to manage/modify 
> > its scheduler.
> 
> Since all of the classification we're suggesting is via the kernel, the
> administrator has the same kinds of controls and it is also without any
> application modifications.

How do you change the scheduler's proportions? Not the classification
itself which is controlled using iptables.

> 
> We're saying, to classify packets so that they get prioritized however you
> would have prioritized things in the accept queue (ie. mark SYN packets
> with address X as having priority Y).  The let the packet scheduler or
> netfilter take care of the rest.

In the in-kernel accept queues the netfilter MARKs it and the packet
is queued to the relevant accept queue. Where and how is the packet getting
queued to a differnt socket (address mangling?)? 

> 
> 
