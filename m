From: Gandalf The White <gandalf@digital.net>
Subject: Re: Fragmentation Attack
Date: Wed, 11 Feb 2004 20:20:19 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BC503F03.E5D9%gandalf@digital.net>
References: <20040208131826.104eaef4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Linux IPStack <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040208131826.104eaef4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings and Salutations:

On 2/8/04 3:18 PM, "David S. Miller" <davem@redhat.com> wrote:
> In this day and age, and with all the headaches fragmentation causes
> (either directly or indirectly via these resource consumption DoS's)
> we may soon be reaching the point where only talking to sites doing
> path-MTU discovery (yes, even for UDP) is a valid decision for a big
> site.
> This would solve the problem in a hurry.

For good or bad, IPV6 carries fragmentation with it.  Indeed it is a little
further in the header, but fragmentation is still there.

It was my hope that this group would be able to come up with a better
algorithm to (more) efficiently handle IP fragments.  Whatever the algorithm
now it is doing a fairly good job.

Like it or not fragmentation is here to stay for your and my lifetime.  Yes,
I agree that sites would be better off not allowing fragmentation.  They
might be better off doing MTU discovery but that protocol can also be used
to map out networks.

The best solution is unfortunately placed on the software engineers that
design the software.  The software has to be as efficient as possible.  The
engineers can only hope that CPU and / or NIC speed will outpace the speed
at which data is transmitted thereby making the CPU / NIC able to handle
anything thrown at it.

I am a network administrator (I also design and install networks).  I work
with routers, switches, firewalls, VPNs, nothing above layer 4.  From what I
have seen of server administrators in my past I don't have much faith in
them being able to handle "network" problems.  Instead of methodical
troubleshooting many have the "keep stabbing in the dark until it works then
leave it alone" attitude (and they never know why it works when it does).

At many companies these server admins are called "Network Administrators".
They are expected to know how to not only set up servers, but to know how to
run the network (from managements limited knowledge those are the same
things).  To expect them to know such arcane IP concepts as MTU path
discovery and fragmentation is (IMHO) asking too much.  They are lucky to be
able to tell the difference between IP or IPX, TCP UDP or ICMP.

As systems get more and more complex we, the technologists creating these
systems are going to have to simplify and automagically protect users and
administrators from themselves as best we can.  Turn on all the autoupdates
we can and make a standard install start as few services as possible.  Allow
the system administrators with knowledge to shut down autoupdates and turn
up services that they need, but only if they are technically savvy enough to
know to do these things.

My 2 cents worth.

Thank you for listening.

Ken

---------------------------------------------------------------
Do not meddle in the affairs of wizards for they are subtle and
quick to anger.
Ken Hollis - Gandalf The White - gandalf@digital.net - O- TINLC
WWW Page - http://digital.net/~gandalf/
Trace E-Mail forgery - http://digital.net/~gandalf/spamfaq.html
Trolls crossposts - http://digital.net/~gandalf/trollfaq.html
