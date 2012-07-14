From: Willy Tarreau <w@1wt.eu>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 10:31:36 +0200
Message-ID: <20120714083136.GO16256@1wt.eu>
References: <20120713171835.GA26052@vault.local> <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com> <1342254042.3265.9017.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hillf Danton <dhillf@gmail.com>,
	Johannes Truschnigg <johannes@truschnigg.info>,
	linux-kernel@vger.kernel.org, Linux-Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342254042.3265.9017.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 14, 2012 at 10:20:41AM +0200, Eric Dumazet wrote:
> > On Tue, Jul 3, 2012 at 8:02 AM, Willy Tarreau <w@1wt.eu> wrote:
> > >
> > > In fact it has been true zero copy in 2.6.25 until we faced a large
> > > amount of data corruption and the zero copy was disabled in 2.6.25.X.
> > > Since then it remained that way until you brought your patches to
> > > re-instantiate it.
> 
> Might be, or not (could be a NIC bug)

I may be wrong but what I recall from this bug was an issue when
forwarding TCP between two NICs, related to linear vs non-linear
data (I have memories of something around data not yet ACKed being
replaced before being retransmitted but I may be wrong). Anyway,
the way it was fixed consisted in simply disabling the zero-copy
code path. So this should be something different from what Johannes
reports. Maybe a regression since then though.

> Please Johannes could you try latest kernel tree ?

It would be useful, especially given the amount of changes you performed
in this area in latest version, it could be very possible that this new
bug got fixed as a side effect !

Regards,
Willy
