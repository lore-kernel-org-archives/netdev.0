From: jamal <hadi@cyberus.ca>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: 04 Nov 2003 22:00:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068001237.1064.31.camel@jzny.localdomain>
References: <1067285612.552.9.camel@aphrodite.olympus.net>
	 <20031028014223.129933be.davem@redhat.com>
	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, Mikkel Christiansen <mixxel@cs.auc.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Emmanuel Fleury <fleury@cs.auc.dk>
In-Reply-To: <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 2003-10-28 at 05:07, Emmanuel Fleury wrote:
> Hi,
> 
> On Tue, 2003-10-28 at 10:42, David S. Miller wrote:
> > On Mon, 27 Oct 2003 21:13:32 +0100
> > Emmanuel Fleury <fleury@cs.auc.dk> wrote:
> > 
> > > For more details check out the netkeeper web-site:
> > >     http://www.cs.auc.dk/~fleury/netkeeper/
> > 
> > You may want to have a look at:
> > 
> >   http://www.cyberus.ca/~hadi/patches/action/README
> > 
> > which I believe is the way to implement these kinds
> > of things.
> 
> Actually, that is exactly the direction which we have been aiming at.


You seem to be attempting to replicate that functionalilty actually;->
(as opposed to using it). Therefore you are going to miss a lot of good
things. What was posted already is just the beggining.
If you want to incorporate i can send you the latest patches (posted
patches have intentional bugs to see who is actually testing). You seem
to be already hooking into netfilter btw so not sure how easy it would
be for you;
Why do you have a limit to 8 actions?

BTW, since you compile your filters, how fast are you at adding rules?
What about dynamic in kernel rules (such as those that may be created by
contracking) - do you have to cross to user space to compile them?
- Is there any reason you move the commit decision to the kernel?
Could this not have been done in user space?
I have doubts how fast you can install rules - which is a fundamental
measure of good filters.

cheers,
jamal
