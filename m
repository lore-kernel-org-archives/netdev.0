From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 10:43:11 +0100
Message-ID: <451501AF.2040209@nuim.ie>
References: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00>
 <4514D590.9010201@nuim.ie>
 <56271.66.57.32.78.1158997517.squirrel@webmail.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Injong Rhee <rhee@eos.ncsu.edu>, floyd@icsi.berkeley.edu,
	netdev@vger.kernel.org, end2end-interest@postel.org,
	lisongxu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:29895 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S1751427AbWIWJoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 05:44:34 -0400
Received: from [192.168.0.2] ([212.2.173.133])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7J5EYT1OW00V303@NUIM.IE>
 for netdev@vger.kernel.org; Sat, 23 Sep 2006 10:44:43 +0000 (GMT)
In-reply-to: <56271.66.57.32.78.1158997517.squirrel@webmail.ncsu.edu>
To: rhee@ncsu.edu
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > I was not sure whether this whole new page is good enough to make another
 > public announcement about this paper

At the risk of repeating myself, the page referred to contains the 
results of approx. 500 new test runs (and we have carried out many more 
than that which are summarised in the text) and directly addresses the 
primary concern raised by yourself and others that situations with a mix 
of connection lengths may lead to significantly different conclusions 
from tests with only long-lived flows.  Our finding is that, for the 
metrics studied, the mix of flow sizes makes little difference to our 
conclusions.  That, combined with the scrutiny provided by the peer 
review process, greatly strengthens our conclusions and certainly seems 
worth reporting.

 > I am not doubting your effort here and I am sure your methods are 
correct.
 > Just i was pondering why we got different results and try to see if 
we can
 > come to some understanding on this different results we got. Who knows we
 > together might run into some fundamental research issues regarding
 > testing.

I'm certainly up for taking a closer look at this.


 > Sally's paper on this role of RTT variations provides more
 > scientific explanation on this "dynamics".
 > In case you missed it, here is the link again.
 > http://www.icir.org/models/hotnetsFinal.pdf. Please read Section 3.3.

Section 3.3 of this paper seems to concern "Active Queue Management: 
Oscillations".  The discussion relates to queue dynamics of RED.  How is 
this relevant ?  All of our tests are for drop-tail queues only.

 > Also about mid size flows, I am referring to the flow lifetimes. The mid
 > sized flows cannot be represented well by the Pareto distribution -- the
 > ones that are in the middle of the distribution that heavy tail is not
 > capable of providing with a large number. Since the Pareto distribution
 > (of your web traffic sz) follows the power law, the distribution of flow
 > sizes around the origin (very short-term) is very high while very
 > long-term flows have relatively high probability.

I suspect your answers in the previous point and here just re-emphasise 
my point.  Its not clear for example what actual values of flow lifetime 
you consider "mid-size" nor what the basis for those values is - there 
are a huge number of measurement studies on traffic stats and if the aim 
is to get closer to real link behaviour then it seems sensible to make 
use of this sort of data.   I do agree it might be interesting to see if 
our test results are sensitive to the connection size distribution used, 
although I suspect the answer will be that they are largely insensitive 
- should be easy enough to check though if you'd be kind enough to send 
me details of the sort of distribution you have in mind.

 > That might be the case. Thanks for pointing that out. But it is hard to
 > explain why we got coincidently the same results as the FAST folks.

Its  hard for me to comment without more information - can you post a 
link to the results by the FAST folks that you mention ?  Perhaps they 
also might like to comment here ?  See also the next comment below ...

 > But I think it is more to do with the different
 > setups we have regarding buffer sizes and the maximum bandwidth. FAST
 > doesn't adapt very well especially under small buffers because of this
 > alpha tuning.

I thought you were suggesting in your last post that you obtained 
different results for the *same* setup as us ?  Some clarity here seems 
important as otherwise your comments are in danger of just serving to 
muddy the water.

If the network setup is different, then its maybe no surprise if the 
results are a little different.  Our own experience (and a key part of 
the rationale for our work) underlines the need to carry out tests over 
a broad range of conditions rather than confining testing to a small 
number of specific scenarios (e.g. only gigabit speed links or only 
links with large buffers) - otherwise its hard to get an overall feel 
for expected behaviour.  We did carry out tests for really quite a wide 
range of network conditions and do already comment, for example, that 
FAST performance does depend on the buffer size.

Doug


