From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 31 Jan 2004 12:02:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075568550.1032.13.camel@jzny.localdomain>
References: <1075058539.1747.92.camel@jzny.localdomain>
	 <20040125202148.GA10599@usr.lcm.msu.ru>
	 <1075074316.1747.115.camel@jzny.localdomain>
	 <20040126001102.GA12303@usr.lcm.msu.ru>
	 <1075086588.1732.221.camel@jzny.localdomain>
	 <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <20040126152409.GA10053@louise.pinerecords.com>
	 <1075173275.1039.53.camel@jzny.localdomain>
	 <20040127115917.GA19166@louise.pinerecords.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>, netdev@oss.sgi.com,
        volf@dragon.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20040127115917.GA19166@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Tomas,

Sorry - didnt mean to keep you hanging this long. Work comes first
then fun stuff like this.

On Tue, 2004-01-27 at 06:59, Tomas Szepe wrote:
> On Jan-26 2004, Mon, 22:14 -0500
> jamal <hadi@cyberus.ca> wrote:
[..]
> Thanks for your reply, Jamal.  Unfortunately, we don't really understand
> your example.  Please see below.
> 

How about we take this offline. I help you and you document it so other
people understand it?

> What's the mechanism for matching the IPs?  We need to insert
> thousands of these rules and shape constant 20+ Mbit flow of
> traffic.  If it doesn't use a hash or similar, we're back to
> where we started.

Its the u32 classifier which is more sophisticated than the standard
iptables one. It does go into a tree of hashes. If you are unhappy with
it, it is trivial to add your own classifier as well.

[..]

> 
> Would you know of any real documentation on tc/ingress that
> we could use to deconstruct this example and understand it?
> 

Lets take it offline - there is no docs really. In particular this 
feature i am talking about is not documented anywhere. Unfortunately
what that means is people reinvent it every summer. IMQ being one of
those inventions.
 
I would like to also satisfy Vladmirs requirement of delaying packets
instead of policing them.

cheers,
jamal
