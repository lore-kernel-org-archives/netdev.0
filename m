From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 22:41:51 +0100
Message-ID: <20050221214151.GZ31837@postel.suug.ch>
References: <200502210332.j1L3WkDD014744@guinness.s2io.com> <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch> <1108994621.1089.158.camel@jzny.localdomain> <20050221141714.GV31837@postel.suug.ch> <1108996313.1090.178.camel@jzny.localdomain> <20050221153443.GW31837@postel.suug.ch> <1109000925.1076.3.camel@jzny.localdomain> <20050221164006.GY31837@postel.suug.ch> <1109005385.1074.68.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1109005385.1074.68.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1109005385.1074.68.camel@jzny.localdomain> 2005-02-21 12:03
> Most of this came after SUCON actually after the BSD folks claimed to be
> doing 1Mpps forwarding (only to find out they used CSA later).

Got it, found your patches.

> Look at the case where we have 32 bit bus in those slides; in that
> scenario we do see an improvement with batching (but really for the
> wrong reasons). The next piece of hardware we see infact a degradation
> in perfomance.

I see, thanks for the elaboration.

> I said in some cases it does make sense (as in the case of 32 bit bus
> above) in some it doesnt (as in the case of  most xeon boards, fast CPU,
> fast PCI-X). 

Yes of course, I left the 32bit bus out, it shouldn't be used as a
data point for optimizations since everyone interested in such
optimizations is unlikely to use such hardware.

> Any solution should be where things work all the time or most of the
> time and are not very hardware specific. If we can hit 95% of the cases,
> then it would make sense to do submit such the patch. Otherwise
> it was a good exercise for me, but useless in general. I do plan to work
> on trying out some heuristics like discovering a few things (such as CPU
> speed, runtime congestion etc) before activating the batching code.
> Wont have time for at least 1 month.

Agreed. Thanks.
