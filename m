From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 04 Jan 2005 21:54:54 -0500
Message-ID: <1104893694.1124.37.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <1104812028.1085.50.camel@jzny.localdomain>
	 <20050104122738.GG26856@postel.suug.ch>
	 <1104844935.1085.103.camel@jzny.localdomain>
	 <20050104134126.GJ26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050104134126.GJ26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-04 at 08:41, Thomas Graf wrote:
> * jamal <1104844935.1085.103.camel@jzny.localdomain> 2005-01-04 08:22
> > On Tue, 2005-01-04 at 07:27, Thomas Graf wrote:
 
> > I am pretty sure someone who knows u32 well can outperform you (in the
> > scenarios where u32 works using AND etc).
> > Start hitting 50K rules then lets talk ;->
> 
> Sure but I'd call a filter with 50K ANDed rules an unlikely scenario ;->

50K matches is probably senseless - i was talking about rules (which
contain matches). 

> In most cases logic will beat brute force. I used to have a u32 setup
> with 4K matches and hashing, it was not only error prone but could be
> replaced with 12 egp filters gaining 90kpps. Why's that? Simply because
> it was easier to optimize the logic behind it. egp itself is terribly
> slow compared to u32.

I think this is a debate that can be easily settled ;->
Agreed logic will beat brute force smartness and u32 is not exactly
for the faint hearted. And its usability is extremely poor - but lets
maintain its power as is.

> > If your intent is to write an ematch holder, then it would be worth to
> > at least go as far as making it some basic hash - as basic as fw does;
> > where collision leads toa linked list. If it is just to show an example,
> > then it is fine.
> 
> Using what key? We have no knowledge about what the ematches want to
> see or not.

Ok, good question ;->
Maybe you should have own some 32 bit key?

cheers,
jamal
