From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 28 Sep 2004 22:54:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096426464.1045.133.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
	 <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
	 <1093906592.1037.32.camel@jzny.localdomain>
	 <20040830160052.548c4846.davem@redhat.com>
	 <1093916592.1037.51.camel@jzny.localdomain>
	 <20040830191716.0d002f91.davem@redhat.com>
	 <1093919823.1043.80.camel@jzny.localdomain>
	 <20040830212910.78047bcd.davem@davemloft.net>
	 <20040929003656.GX31616@rei.reeler.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040929003656.GX31616@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 20:36, Thomas Graf wrote:
> * David S. Miller <20040830212910.78047bcd.davem@davemloft.net> 2004-08-30 21:29
> > Look, let's get real about this topic.  We can't be breaking shit
> > like this all the time.  We're nearly letting it happen a lot
> > lately.
> > 
> > These data structures are user visible APIs, they are just like
> > system call data structures, and if we cannot modify
> > them without potentially breaking some existing application we
> > cannot make that change.
> 
> Why not do it by using nested TLVs?:
> 
>   TCA_STATS2 [
>       TCA_STAT_BYTES
>       TCA_STAT_PACKETS
>       TCA_STAT_DROPS
>       ...
>   ]

Refer to my earlier email; i think this is a noble approach.
Lets do it on gnet stats though so we can make it more accessible.
I think your granularity maybe too thin: bytes,packets, drops
may need to be in the same TLV.

> This way we can add as many new stats as we want without
> even thinking about backward compatibility in the future.
> This would also allow to implement dynamic size statistics
> or introduce TCA_STAT_*_64 if ever needed.

Yep.
do you have cycles to run with that patch?

cheers,
jamal
