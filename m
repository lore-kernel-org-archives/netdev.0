From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 01 Feb 2005 07:02:41 -0500
Message-ID: <1107259361.1095.584.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <20050131135810.GC31837@postel.suug.ch>
	 <1107181169.7840.184.camel@jzny.localdomain>
	 <20050131151532.GE31837@postel.suug.ch>
	 <1107186044.1076.11.camel@jzny.localdomain>
	 <20050131155929.GF31837@postel.suug.ch>
	 <1107189625.1076.77.camel@jzny.localdomain>
	 <20050131181553.GG31837@postel.suug.ch>
	 <1107202715.1075.559.camel@jzny.localdomain>
	 <20050131225328.GI31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131225328.GI31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 17:53, Thomas Graf wrote:

> I was thinking of the parameters to define what a flow consists of.
> Extended SFQ basically allows you to define the hash function. I think
> I misunderstood you before and you don't want allow adjustable
> states on only a subset of the attributes, e.g. only L3 data.

Why bother putting extra classifier functionality into a qdisc? 
you should be able to rip off the classifier from sfq so you dont depend
on it; you can then select one of n queues (eaction meta set class 1:X
based on result of sfq classifier - or you can have it set the classids
based on resulting hash index) 

> > I think the eactions etc are adding a lot of value towards usability.
> > Hasso Tepper was ealrier complaining about this same issue. 
> > As an example, I think u32 and ematches would improve a great deal now
> > and be more understandable. True, work/time still needs to be invested.
> 
> I'd guess that the basic classifier will make the race because the
> documentation will be smaller due to the lack of parameters. ;->

Well, even if it is just being able to describe in english the u32
parameters and displaying them in english (by using a ID stored)
its already huge progress.

> But yes I agree, I think we're making small step forwards and hopefully
> the network config shell/tool/whatever will ease the steps to configure
> things. My primary goal is to allow using it without looking up
> parameters all the time, given one is aware of the common terms and basic
> concepts. 

Online easy to use help is always valuable.

> I'll have some more time next week and will try to implement the
> traffic control bits or at least some of them. The wind forecast is pretty
> good for the next days so I won't have too much time. ;->

Weather is also predicted to be good here for the week; we are planning to 
get out of our igloos and go tobagoning;->

cheers,
jamal
 
