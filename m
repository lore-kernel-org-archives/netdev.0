From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 04 Jan 2005 08:22:15 -0500
Message-ID: <1104844935.1085.103.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <1104812028.1085.50.camel@jzny.localdomain>
	 <20050104122738.GG26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050104122738.GG26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-04 at 07:27, Thomas Graf wrote:
> * jamal <1104812028.1085.50.camel@jzny.localdomain> 2005-01-03 23:13

> > Very inefficient, but serves the purpose of an example.
> > [Even if you go as basic a hash as fw classifier you will do better]
> 
> Might be worth to mention the motivation for this. fw and u32
> will definitely perform much better on complex setups but
> many do not use u32 hashing not to mention even understand it
> or have large nfmark -> classid fw maps.

agreed.

> Many use u32 to match simple stuff as port numbers, dscp values
> or ip subnet addresses and create a new filter for every port/dscp
> value and for every address. Some even use temporary classes to
> emulate logic relations and this gets really slow. I have to get
> numbers first but a single basic filter with ORed matches is probably
> faster than a separate u32 filter for every case.

I am pretty sure someone who knows u32 well can outperform you (in the
scenarios where u32 works using AND etc).
Start hitting 50K rules then lets talk ;->

>  Sure, once u32
> has ematch support it gets better and the hashing shouldn't have
> too much influence even if it's unused.. We can see what to do once
> u32 can handle ematches.

If your intent is to write an ematch holder, then it would be worth to
at least go as far as making it some basic hash - as basic as fw does;
where collision leads toa linked list. If it is just to show an example,
then it is fine.

cheers,
jamal
