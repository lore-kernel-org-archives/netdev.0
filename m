From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Wed, 12 Sep 2007 08:12:22 -0400
Message-ID: <1189599142.4326.38.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	 <1189120020.4259.68.camel@localhost> <46E11A61.9030409@katalix.com>
	 <1189171370.4234.38.camel@localhost>
	 <20070912030428.16059af6.billfink@mindspring.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jeff@garzik.org, mandeep.baines@gmail.com,
	ossthema@de.ibm.com, Stephen Hemminger <shemminger@osdl.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:52207 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966458AbXILMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:12:27 -0400
Received: by an-out-0708.google.com with SMTP id d31so17166and
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 05:12:26 -0700 (PDT)
In-Reply-To: <20070912030428.16059af6.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-12-09 at 03:04 -0400, Bill Fink wrote:
> On Fri, 07 Sep 2007, jamal wrote:

> > I am going to be the devil's advocate[1]:
> 
> So let me be the angel's advocate.  :-)

I think this would make you God's advocate ;->
(http://en.wikipedia.org/wiki/God%27s_advocate)

> I view his results much more favorably.  

The challenge is, under _low traffic_: bad bad CPU use.
Thats what is at stake, correct?

Lets bury the stats for a sec ...

1) Has that CPU situation improved? No, it has gotten worse.
2) Was there a throughput problem? No. 
Remember, this is _low traffic and the complaint is not NAPI doesnt do
high throughput. I am not willing to spend 34% more cpu to get a few
hundred pps (under low traffic!). 
3)Latency improvement is good. But is 34% cost worthwile for the corner
case of low traffic?

Heres an analogy:
I went to buy bread and complained that 66cents was too much for such
a tiny sliced loaf.
You tell me you have solved my problem: asking me to pay a dollar
because you made the bread slices crispier. I was complaining on the _66
cents price_ not on the crispiness of the slices ;-> Crispier slices are
good - but am i, the person who was complaining about price, willing to
pay 40-50% more? People are bitching about NAPI abusing CPU, is the 
answer to abuse more CPU than NAPI?;->
The answer could be "I am not solving that problem anymore" - at least
thats what James is saying;->

Note: I am not saying theres no problem - just saying the result is not
addressing the problem.

> You can't always improve on all metrics of a workload.  

But you gotta try to be consistent. 
If, for example, one packet size/rate got negative results but the next
got positive results - thats lacking consistency. 

> Sometimes there
> are tradeoffs to be made to be decided by the user based on what's most
> important to that user and his specific workload.  And the suggested
> ethtool option (defaulting to current behavior) would enable the user
> to make that decision.

And the challenge is:
What workload is willing to invest that much cpu for low traffic?
Can you name one? One that may come close is database benchmarks for
latency - but those folks wouldnt touch this with a mile-long pole if
you told them their cpu use is going to get worse than what NAPI (that
big bad CPU hog under low traffic) is giving them.

> 
> P.S.  I agree that some tests run in parallel with some CPU hogs also
>       running might be beneficial and enlightening.

indeed.

cheers,
jamal

