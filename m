From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 13:20:44 -0400
Message-ID: <1494955244.3259.130.camel@redhat.com>
References: <1494950224.3259.98.camel@redhat.com>
         <20170516.122923.869994491617365845.davem@davemloft.net>
         <1494952963.3259.109.camel@redhat.com>
         <20170516.124945.386235742645153398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516.124945.386235742645153398.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 12:49 -0400, David Miller wrote:
> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 16 May 2017 12:42:43 -0400
> 
> > On Tue, 2017-05-16 at 12:29 -0400, David Miller wrote:
> >> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> Date: Tue, 16 May 2017 11:57:04 -0400
> >> 
> >> > Regardless though, I'm rather purturbed about this entire thing.
> >>  If
> >> > you are right that because this got into 4.11, it's now a done
> >> deal,
> >> > then the fact that this went through 4 review cycles on netdev@
> >> that,
> >> > as I understand it, spanned roughly one years time, and not one
> >> single
> >> > person bothered to note that this was as much an RDMA driver as
> >> > anything else, and not one person bothered to note that linux-
> rdma@ 
> >> was
> >> > not on the Cc: list, and not one person told the submitters that
> >> they
> >> > needed to include linux-rdma@ on the Cc: list of these
> submissions,
> >> and
> >> > you took it without any review comments from any RDMA people in
> the
> >> > course of a year, or an ack from me to show that the RDMA
> portion
> >> of
> >> > this had at least been given some sort of review, was a collosal
> >> fuckup
> >> > of cross tree maintainer cooperation.
> >> 
> >> We rely on people from various areas of expertiece to contribute
> to
> >> patch review on netdev and give appropriate feedback.
> >> 
> >> If you actually look through the history, I made many semantic
> >> reviews
> >> of the SMC changes, and kept pushing back.
> >> 
> >> And in fact I did this several times, making them go through
> several
> >> revisions, in the hopes that someone would review more of the meat
> >> and
> >> substance of the patch set.
> > 
> > If you want to walk to the mailbox, you walk to the mailbox, you
> don't
> > walk to the grocery store, to the gym, and never even go to the
> > mailbox.  Likewise, if you want review from RDMA experts, most
> (maybe
> > even all) don't subscribe to netdev@ because it's too high traffic,
> you
> > don't waste time on silly semantic pushbacks, you send a single
> email
> > that says "Please get review from linux-rdma@, thank you."  Don't
> beat
> > around the bush, be direct and get it over with.  That's exactly
> what I
> > do for all netdev@ related patches coming to linux-rdma@ without a
> > proper Cc: to netdev@.
> 
> Read my other email, it wasn't %100 clear to me that this was so
> strictly RDMA related.  And I kept pushing back with semantic changes
> in part because it wasn't clear.

See my other email.  I think in the fact that you are overloaded on
netdev@ you skimmed the cover letter, which is the one thing that would
have made things clear.

> So as far as I was concerned I was not necessarily going to the wrong
> store, in fact I wasn't sure what store to go to.
> 
> And none of the thousands of subscribers to netdev intuit'd this
> either.  Maybe there is a reason for that.

Yeah, it's an overloaded list would be my guess.  I imagine no one can
keep up with it fully in truth.  Maybe it's time to split some of it
out into sublists?  netdev-core/netdev-ethernet/netdev-packet?  I don't
know, but I know I can't keep up with it.  That you do as well as you
do is probably only because you know how to not spend too much time on
any one thing.  I'm sure you have people you know are submitting
important work that effects the overall net subsystem and you focus on
their stuff, but ancillary things probably only get half attention at
double speed in order to allow you to make it through the day.

> Furthermore, if netdev is too much traffic for one or two RDMA people
> to just casually subscribe to on the off chance that a situationm
> like
> this comes up, guess what it is like for me who has to read and
> review
> pretty much every single posting that is placed there?

I get it.  I don't have the time to both be responsible for linux-rdma
and follow netdev.  I can already tell you what would happen if I
tried.  Eventually netdev would get so far behind I would just mass
delete and start over.  So that doesn't solve the problem.

Anyway, we're just talking out what happened, when what we really need
to focus on is moving forward.  Again, your thoughts on marking SMC
EXPERIMENTAL until it's fixed up and unfreezing the API in case we need
to adjust it to work on different link layers?

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
