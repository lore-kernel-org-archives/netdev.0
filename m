From: jamal <hadi@cyberus.ca>
Subject: Re: udp weirdness
Date: Mon, 30 Sep 2002 07:09:56 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209300703411.11444-100000@shell.cyberus.ca>
References: <20020930084903.GA359@hookipa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@sun.com>
In-Reply-To: <20020930084903.GA359@hookipa>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 30 Sep 2002, Eric Lemoine wrote:

> > Ok, understood. Actually we already seem to have enobufs being returned.
> >
> > Eric,
> > Does the attached patch fix it? Not tested or even compiled.
> > Someone going to change the manpages?
>
> protinfo.af_inet.recverr is a flag (1-bit variable) to enable the
> "extended reliable error message passing"; I dont see any reason
> for modifying it here. Setting this flag is the user's responsability,
> isn't it?

I dont see any reason for modifying it there either - it is used for
mostly for incoming ICMP errors; but the original piece of code was
modifying it so i left it as is; however, thats not what you were chasing
and i dont see how what you just posted is solving your problem.
Did you even bother to test what i sent you? Or for that matter
bother testing what you posted?

cheers,
jamal
