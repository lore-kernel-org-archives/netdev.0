From: John Heffner <jheffner@psc.edu>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 10:37:59 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0403171000060.13117-100000@dexter.psc.edu>
References: <20040316174134.2f1da12a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040316174134.2f1da12a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Mar 2004, David S. Miller wrote:

> On Tue, 16 Mar 2004 15:10:58 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
>
> > Probably "the cowboy way" would be to right a new net/scheduler to just
> > do FIFO delay.
> >
> > Any ideas/comments? Somebody have some code sitting in a drawer?
>
> Probably a packet scheduler would be my first choice, you could then even
> tag packets using classification and therefore delay differently for different
> flows.

One insight I had a while ago is that packet pacing and artificial delay
require a very similar mechanism.  I hacked something a while ago that did
this in a general way, though it had some problems and I never really
followed up on it.  Given the recent discussion of pacing on linux-net,
this might be something to think about.

  -John
