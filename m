From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 21:25:53 -0700
Message-ID: <20060923212553.7239d0aa@localhost.localdomain>
References: <003001c6deba$099411e0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23782 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752115AbWIXE0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 00:26:07 -0400
To: "Injong Rhee" <rhee@eos.ncsu.edu>
In-Reply-To: <003001c6deba$099411e0$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 22:43:22 -0400
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> This is a resend with fixed web links. The links were broken in my previous 
> email -- sorry about multiple transmissions.
> ---------------------------------------------------------------------------------
> Hi Doug,
> Thanks for sharing your paper. Also congratulations to the acceptance of 
> your journal paper to TONs. But I am wondering what's new in this paper. At 
> first glance, I did not find many new things that are different from your 
> previously publicized reports. How much is this different from the ones you 
> put out in this mail list a year or two ago and also the one publicized in 
> PFLDnet February this year http://www.hpcc.jp/pfldnet2006/? In that same 
> workshop, we also presented our experimental results that shows significant 
> discrepancy from yours but i am not sure why you forgot to reference our 
> experimental work presented in that same PFLDnet. Here is a link to a more 
> detailed version of that report accepted to COMNET 
> http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf
> 
> The main point of contention [that we talked about in that PFLDnet workshop] 
> is the presence of background traffic and the method to add them. Your 
> report mostly ignores the effect of background traffic. Some texts in this 
> paper state that you added some web traffic (10%), but the paper shows only 
> the results from NO background traffic scenarios. But our results differ 
> from yours in many aspects. Below are the links to our results (the links to 
> them have been available in our BIC web site for a long time and also 
> mentioned in our PFLDnet paper; this result is with the patch that corrects 
> HTCP bugs).
> 
> [Convergence and intra protocol fairness]
> without background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/intra_protocol.htm
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra_protocol.htm
> 
> [RTT fairness]:
> w/o background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_fairness.htm
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fairness.htm
> 
> [TCP friendliness]
> without background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/tcp_friendliness.htm
> with background traffic: 
> http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp_friendliness.htm
> 
> After our discussion in that PFLDnet, I puzzled why we get different 
> results. My guess is that the main difference between your experiment and 
> ours is the inclusion of mid-sized flows with various RTTs -- our experience 
> tells that the RTT variations of mid size flows play a very important role 
> in creating significant dynamics in testing environments. The same point 
> about the importance of mid size flows with RTT variations has been raised 
> in several occasions by Sally Floyd as well, including in this year's E2E 
> research group meeting. You can find some reference to the importance of RTT 
> variations in her paper too [ http://www.icir.org/models/hotnetsFinal.pdf]. 
> Just having web-traffic (all with the same RTTs) does not create a realistic 
> environment as it does not do anything about RTTs and also flow sizes tend 
> to be highly skewed with the Pareto distribution-- but I don't know exactly 
> how you create your testing environment with web-traffic -- I can only guess 
> from the description you have about the web traffic in your paper.
> 
> Another puzzle in this difference seems that even under no background 
> traffic, we also get different results from yours..hmm...especially with 
> FAST because under no background traffic, FAST seems to work fairly well 
> with good RTT fairness in our experiment. But your results show FAST has 
> huge RTT-unfairness. That is very strange. Is that because we have different 
> bandwidth and buffer sizes in the setup? I think we need to compare our 
> notes more. Also in the journal paper of FAST experimental results [ 
> http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf ], 
> FAST seems to work very well under no background traffic. We will verify our 
> results again in the exact same environment as you have in your report, to 
> make sure we can reproduce your results....but here are some samples of our 
> results for FAST.
> http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200--2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-1000-10-1200-64000-150--1/
> In this experiment, FAST flows are just perfect. Also the same result is 
> confirmed inthe FAST journal paper [ 
> http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf --  
> please look at Section IV.B and C. But your results show really bad RTT 
> fairness.]
> 
> Best regards,
> Injong

Since a lot of the discussion seems to be about emulated environments,
has anyone run tests with the current crop of TCP variants over a real
high BDP network? The SLAC testbed stuff http://www-iepm.slac.stanford.edu/bw/tcp-eval/ 
was last updated in 2003. Since real world traffic is so complex, and
there could easily be higher order effects, I would prefer that the 
Linux defaults be based on observed behaviour. Just like the choice of
I/O scheduler and other heuristics is optimized to be right for
real workloads.
