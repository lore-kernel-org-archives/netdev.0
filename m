From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Tue, 11 Jun 2002 18:41:16 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae5uq2$i5t$2@main.gmane.org>
References: <20020609.213440.04716391.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: greearb@candelatech.com, mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020609.213440.04716391.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Sun, 9 Jun 2002, David S. Miller wrote:

>    From: Ben Greear <greearb@candelatech.com>
>    Date: Sun, 09 Jun 2002 11:23:30 -0700
>    
>    I need to account for packets on a per-session basis, where a
>    session endpoint is a UDP port.  So, knowing global protocol numbers is
>    good, but it is not very useful for the detailed accounting I
>    need.
> 
> Why can't you just disable the other UDP services, and then there is
> no question which UDP server/client is causing the drops.

  Should be obvious that if a combination of load and client behaviour
cause the problem you will learn nothing.
 
> Every argument I hear is one out of lazyness.  And that is not a
> reason to add something.  Simply put, I don't want to add all of this
> per-socket counter bumping that only, at best, 1 tenth of 1 percent
> of people will use.  This means that the rest of the world eats the
> overhead just for this small group that actually uses it.

  Actually your arguments sound like you have a solution to your problem
and you want everyone to use it even if it doesn't help them. Have you
some emotional tie to SNMP, like being an author?

  There is no overhead unless the config option is selected, which would
be done in a normal kernel source, just as verbose messages, highmem
debugging, singing and dancing SYSREQ, debugging SCSI driver, and many,
many other features. So the argument against load is totally irrelevant.

  I can't see why anyone would be against a feature just because they
don't personally use it, there is so much stuff of specialized use now,
that a it sure sounds like existing practice. I even think that the
implementation is general and could be extended to gather other
per-connection stats which is a big plus in terms of design quality.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.
