From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 10 Jan 2005 17:05:38 -0500
Message-ID: <1105394738.1085.63.camel@jzny.localdomain>
References: <20050104223612.GN26856@postel.suug.ch>
	 <1104894728.1117.56.camel@jzny.localdomain>
	 <20050105110048.GO26856@postel.suug.ch>
	 <1104931991.1117.152.camel@jzny.localdomain>
	 <20050105144514.GQ26856@postel.suug.ch>
	 <1105019225.2312.7.camel@jzny.localdomain>
	 <20050106194102.GW26856@postel.suug.ch>
	 <1105105511.1046.77.camel@jzny.localdomain>
	 <20050108145457.GZ26856@postel.suug.ch>
	 <1105363582.1041.162.camel@jzny.localdomain>
	 <20050110211747.GA26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050110211747.GA26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-10 at 16:17, Thomas Graf wrote:
> * jamal <1105363582.1041.162.camel@jzny.localdomain> 2005-01-10 08:26
> > I think its _a hack_ Thomas ;-> Mostly because it has dependency on u32.
> > off2 doesnt exist on any other classifier and the basic ematch should be
> > usable by any classifier.
> 
> It does not, u32 does have a dependency on em_u32 but not vice versa.
> em_u32 is perfectly useful even without nexthdr functionality since
> this is the way it is used today in 90% of the cases and it should be
> a little bit faster than em_cmp but also a bit less powerful. On top
> of that, rsvp could provide this information as well so one could
> extend rsvp with em_u32 ematches. I think we should not think of it
> as being dependant on off2 but rather as it is able to use information
> from a underlying layer.

Ok, you make a convincing arguement ;-> No more concerns from my side.
Churn that code!

cheers,
jamal
