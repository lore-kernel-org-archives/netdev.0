From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 16:12:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <29290000.1056755566@[10.10.2.4]>
References: <3EFCBD12.3070101@candelatech.com><20030627.145456.115915594.davem@redhat.com><3EFCC1EB.2070904@candelatech.com> <20030627.151906.102571486.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidel@xmailserver.org, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, greearb@candelatech.com
In-Reply-To: <20030627.151906.102571486.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--"David S. Miller" <davem@redhat.com> wrote (on Friday, June 27, 2003 15:19:06 -0700):

>    From: Ben Greear <greearb@candelatech.com>
>    Date: Fri, 27 Jun 2003 15:15:07 -0700
> 
>    Forcing people to continue to retransmit the same report just pisses
>    people off, and in the end will get you less useful reports than if
>    you had flagged the report as 'please-gimme-more-info'.
> 
> And this is different from patch submission in what way?
> 
>    Perhaps, but it's also possible that you are being a stubborn SOB
>    because you fear change :)
>    
> Absolutely not, in fact I'm daily looking for ways to change how
> I work with people who help me so that I scale better.  And I know
> for sure that a bug datamase with shit that accumulates in it
> that _REQUIRES_ me to do something about it to make it go away
> does not help me scale.
> 
> Bugme was an absolute burdon for me.
> 
> For something to scale, it must continute to operate just as
> efficiently if I were to go away for a few weeks.  The lists have that
> quality, the bug database with owner does not.

OK, both the scaling thing and the vacation issue are valid complaints,
but they're both easy to fix. I realise you're busy, but we can easily
just set this up to go to a list of people instead, either including
or not including yourself, as you wish. If you don't wish to see bugs
after the first time, and just "let them fall through the cracks", then
feel free to do so.

> I know that's a hard pill to swallow, but over years of work I can
> tell you this is the only scalable mechanism.  Nobody likes this
> because it's not tracked somewhere and they can't show some pretty
> list of bugs to their management at the end of each week, TOO FUCKING
> BAD.  Pay someone to work on your bugs if you want a pretty list and
> people being REQUIRED to look at and fix bugs.  None of this crap is
> my problem.

I am not some corporate process weenie - I hate process, and overhead;
ask anyone at IBM ;-) The whole thing is structured to be pretty 
lightweight, and easy to use, and ditches a whole bunch of stuff that's 
just aimed at tracking and management stats, because I really don't think 
that's something the Linux community gives a shit about, and neither do I.

It's there to help ensure bugs get fixed, and to help both developers
and users of Linux - that's really the only goal. Yes, there's a little
more work for developers to do up front, but I think it pays off long
term (one trivial example is that users will learn to look for a problem
already there before sending a duplicate report). If you don't agree, 
it's easy for you to opt out of being the default owner for bugs, (we 
did that this morning as soon as you asked) but others might still find 
it useful.

M.
