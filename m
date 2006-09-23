From: rhee@ncsu.edu
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 03:45:17 -0400 (EDT)
Message-ID: <56271.66.57.32.78.1158997517.squirrel@webmail.ncsu.edu>
References: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00>
    <4514D590.9010201@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Injong Rhee" <rhee@eos.ncsu.edu>, floyd@icsi.berkeley.edu,
	netdev@vger.kernel.org, end2end-interest@postel.org,
	lisongxu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni01mr.unity.ncsu.edu ([152.1.1.164]:34999 "EHLO
	uni01mr.unity.ncsu.edu") by vger.kernel.org with ESMTP
	id S1751030AbWIWHp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 03:45:56 -0400
In-Reply-To: <4514D590.9010201@nuim.ie>
To: "Douglas Leith" <doug.leith@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Doug Leith wrote-----
> I suggest you take a closer look Injong - there is a whole page of data
> from tests covering a wide range of levels of background traffic.  These
> results are all new, and significantly strengthen the conclusions I
> think, as is the expanded explanatory discussion of the observed
> behaviour of the various algorithms (the result of a fair bit of
> detective work of course).

I was not sure whether this whole new page is good enough to make another
public announcement about this paper -- this paper has been publicized by
you many times in these mailing lists and also in the workshop. It would
have saved us some time if you had just pointed out the new stuff.

>
> I can't really comment on your own tests without more information,
> although I can say that we went to a good bit of trouble to make sure
> our results were consistent and reproducible - in fact all our reported
> results are from at least five, and usually more, runs of each test.

I am not doubting your effort here and I am sure your methods are correct.
Just i was pondering why we got different results and try to see if we can
come to some understanding on this different results we got. Who knows we
together might run into some fundamental research issues regarding
testing.

Also the "more" information about our own experiment is already given in
the paper and also in our web site. If you could tell what specific info
you need more, I can provide. Let's put our heads together to solve this
mystery of "different results".

>
> General comments such as "our experience tells that the RTT variations
> of mid size flows play a very important role in creating significant
> dynamics in testing environments" are not too helpful.  What do you mean
> by a "mid-sized flow" ?  What do you mean by "significant dynamics" ?
> What do you mean by "important role" - is this quantified ?  Best to
> stick to science rather than grandstanding.  This is especially true
> when dealing with a sensitive subject such as the evaluation of
> competing algorithms.

I hope you can perhaps enlighten us with this "science".
 Well..this WAS just email. There wasn't much space to delve into
"science" there. So that is why I gave the link to Floyd and Kohler's
paper. Sally's paper on this role of RTT variations provides more
scientific explanation on this "dynamics".
In case you missed it, here is the link again.
http://www.icir.org/models/hotnetsFinal.pdf. Please read Section 3.3.

Also about mid size flows, I am referring to the flow lifetimes. The mid
sized flows cannot be represented well by the Pareto distribution -- the
ones that are in the middle of the distribution that heavy tail is not
capable of providing with a large number. Since the Pareto distribution
(of your web traffic sz) follows the power law, the distribution of flow
sizes around the origin (very short-term) is very high while very
long-term flows have relatively high probability.

So speaking of "science", can you please tell me whether all flows of your
web traffic have the same RTTs or not? If you could please point me to the
results you have with your web traffic tests instead of simply hand-wavy
about the results saying they are just the same (or similar) as the
results from your NO background traffic tests, I'd appreciate that very
much.

>
> Re FAST, we have of course discussed our results with the Caltech folks.
>   As stated in the paper, some of the observed behaviour seems to be
> associated with the alpha tuning algorithm.  Other behaviour seems to be
> associated with packet burst effects that have also been reported
> independently by the Caltech folks.  Similar results to ours have since
> been observed by other groups I believe.  Perhaps differences between
> our results point to some issue in your testbed setup.

That might be the case. Thanks for pointing that out. But it is hard to
explain why we got coincidently the same results as the FAST folks. Maybe
our and FAST folks' testbeds have "this issue" while yours are completely
sound and scientific. But I think it is more to do with the different
setups we have regarding buffer sizes and the maximum bandwidth. FAST
doesn't adapt very well especially under small buffers because of this
alpha tuning.




