From: Injong Rhee <rhee@eos.ncsu.edu>
Subject: Re: performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Fri, 22 Sep 2006 21:45:26 -0400
Message-ID: <9dbabe09ba99fc423f5f33f51f7fff02@eos.ncsu.edu>
References: <4513F1A1.3000506@nuim.ie>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: multipart/alternative; boundary=Apple-Mail-13-280100244
Cc: netdev <netdev@vger.kernel.org>, Sally Floyd <floyd@ICSI.Berkeley.EDU>,
        lisongxu@gmail.com, end2end-interest@postel.org
Return-path: <end2end-interest-bounces@postel.org>
In-Reply-To: <4513F1A1.3000506@nuim.ie>
To: Douglas Leith <doug.leith@nuim.ie>
List-Unsubscribe: <http://mailman.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://mailman.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://mailman.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail-13-280100244
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

Hi Doug,

Thanks for sharing your paper. Also congratulations to the acceptance  
of your journal paper to TONs. But I am wondering what's new in this  
paper. At first glance, I did not find many new things that are  
different from your previously publicized reports. How much is this  
different from the ones you put out in this mail list a year or two ago  
and also the one publicized in PFLDnet  February this year  
http://www.hpcc.jp/pfldnet2006/? In that same workshop, we also  
presented our experimental results that shows significant discrepancy  
from yours but i am not sure why you forgot to reference our  
experimental work presented in that same PFLDnet. Here is a link to a  
more detailed version of that report accepted to COMNET  
http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf

The main point of contention [that we talked about in that PFLDnet  
workshop] is the presence of background traffic and the method to add  
them. Your report mostly ignores the effect of background traffic.   
Some texts in this paper state that you added some web traffic (10%),  
but the paper shows only the results from NO background traffic  
scenarios. But our results differ from yours  in many aspects. Below  
are the links to our results (the links to them have been available in  
our BIC web site for a long time and also mentioned in our PFLDnet  
paper; this result is with the patch that corrects HTCP bugs).

[Convergence and intra protocol fairness]
without background traffic:  
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/ 
intra_protocol.htm
with background traffic:   
http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/ 
intra_protocol.htm

[RTT fairness]:
w/o background traffic:  
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/ 
rtt_fairness.htm
with background  
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/ 
rtt_fairness.htm

[TCP friendliness]
without background  
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/ 
tcp_friendliness/tcp_friendliness.htm
with background  
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/ 
tcp_friendliness.htm

After our discussion in that PFLDnet, I puzzled why we get different  
results. My guess is that the main difference between your experiment  
and ours is the inclusion of mid-sized flows with various RTTs -- our  
experience tells that the RTT variations of mid size flows play a very  
important role in creating significant dynamics in testing  
environments. The same point about the importance of mid size flows  
with RTT variations has been raised in several occasions by Sally Floyd  
as well, including in this year's E2E research group meeting. You can  
find some reference to the importance of RTT variations in her paper  
too [http://www.icir.org/models/hotnetsFinal.pdf ]. Just having  
web-traffic (all with the same RTTs) does not create a realistic  
environment as it does not do anything about RTTs and also flow sizes  
tend to be highly skewed with the Pareto distribution-- but I don't  
know exactly how you  create your testing environment with web-traffic  
-- I can only guess from the description you have about the web traffic  
in your paper.

Another puzzle in this difference seems that even under no background  
traffic, we also get different results from yours..hmm...especially  
with FAST because under no background traffic, FAST seems to work  
fairly well with good RTT fairness in our experiment. But your results  
show FAST has huge RTT-unfairness. That is very strange. Is that  
because we have different bandwidth and buffer sizes in the setup? I  
think we need to compare our notes more. Also in the journal paper of  
FAST experimental results  
[http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf  
], FAST seems to work very well under no background traffic.  We will  
verify our results again in the exact same environment as you have in  
your report, to make sure we can reproduce your results....but here are  
some samples of our results for FAST.

http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200- 
-2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6 
-1000-10-1200-64000-150--1/

In this experiment, FAST flows are just perfect. Also the same result  
is confirmed inthe  FAST journal paper  
[http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf  
-- please look at Section IV.B and C.  But your results show really bad  
RTT fairness.]

Best regards,
Injong

---
Injong Rhee
NCSU



On Sep 22, 2006, at 10:22 AM, Douglas Leith wrote:

> For those interested in TCP for high-speed environments, and perhaps  
> also people interested in TCP evaluation generally, I'd like to point  
> you towards the results of a detailed experimental study which are now  
> available at:
>
> http://www.hamilton.ie/net/eval/ToNfinal.pdf
>
> This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP,  
> FAST-TCP and H-TCP performance under a wide range of conditions  
> including with mixes of long and short-lived flows.  This study has  
> now been subject to peer review (to hopefully give it some legitimacy)  
> and is due to appear in the Transactions on Networking.
>
> The conclusions (see summary below) seem especially topical as BIC-TCP  
> is currently widely deployed as the default algorithm in Linux.
>
> Comments appreciated.  Our measurements are publicly available - on  
> the web or drop me a line if you'd like a copy.
>
> Summary:
> In this paper we present experimental results evaluating the
> performance of the Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and
> H-TCP proposals in a series of benchmark tests.
>
> We find that many recent proposals perform surprisingly poorly in
> even the most simple test, namely achieving fairness between two
> competing flows in a dumbbell topology with the same round-trip
> times and shared bottleneck link. Specifically, both Scalable-TCP
> and FAST TCP exhibit very substantial unfairness in this test.
>
> We also find that Scalable-TCP, HS-TCP and BIC-TCP induce  
> significantly greater RTT unfairness between competing flows with  
> different round-trip times.  The unfairness can be an order of  
> magnitude greater than that with standard TCP and is such that flows  
> with longer round-trip times
> can be completely starved of bandwidth.
>
> While the TCP proposals studied are all successful at improving
> the link utilisation in a relatively static environment with
> long-lived flows, in our tests many of the proposals exhibit poor
> responsiveness to changing network conditions.  We observe that
> Scalable-TCP, HS-TCP and BIC-TCP can all suffer from extremely
> slow (>100s) convergence times following the startup of a new
> flow. We also observe that while FAST-TCP flows typically converge
> quickly initially, flows may later diverge again to create
> significant and sustained unfairness.
>
> --Doug
>
> Hamilton Institute
> www.hamilton.ie
>
>

--Apple-Mail-13-280100244
Content-Transfer-Encoding: 7bit
Content-Type: text/enriched;
	charset=US-ASCII

Hi Doug,


Thanks for sharing your paper. Also congratulations to the acceptance
of your journal paper to TONs. But I am wondering what's new in this
paper. At first glance, I did not find many new things that are
different from your previously publicized reports. How much is this
different from the ones you put out in this mail list a year or two
ago and also the one publicized in PFLDnet  February this year
<underline><color><param>0000,0000,FFFE</param>http://www.hpcc.jp/pfldnet2006/</color></underline>?
In that same workshop, we also presented our experimental results that
shows significant discrepancy from yours but i am not sure why you
forgot to reference our experimental work presented in that same
PFLDnet. <underline><color><param>0000,0000,FFFE</param>Here is a link
to a more detailed version of that report accepted to COMNET
http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf </color></underline>


The main point of contention [that we talked about in that PFLDnet
workshop] is the presence of background traffic and the method to add
them. Your report mostly ignores the effect of background traffic. 
Some texts in this paper state that you added some web traffic (10%),
but the paper shows only the results from NO background traffic
scenarios. But our results differ from yours  in many aspects. Below
are the links to our results (the links to them have been available in
our BIC web site for a long time and also mentioned in our PFLDnet
paper; this result is with the patch that corrects HTCP bugs). 


[Convergence and intra protocol fairness] 

without background traffic:
<underline><color><param>0000,0000,FFFF</param>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/intra_protocol.htm 

with background traffic: </color></underline>
<underline><color><param>0000,0000,FFFF</param>http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra_protocol.htm 


[RTT fairness]: 

w/o background traffic:
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_fairness.htm 

with background
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fairness.htm 


[TCP friendliness]

without background
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/tcp_friendliness.htm 

with background
traffic:http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp_friendliness.htm 


</color></underline>After our discussion in that PFLDnet, I puzzled
why we get different results. My guess is that the main difference
between your experiment and ours is the inclusion of mid-sized flows
with various RTTs -- our experience tells that the RTT variations of
mid size flows play a very important role in creating significant
dynamics in testing environments. The same point about the importance
of mid size flows with RTT variations has been raised in several
occasions by Sally Floyd as well, including in this year's E2E
research group meeting. You can find some reference to the importance
of RTT variations in her paper too
[<underline><color><param>0000,0000,FFFF</param>http://www.icir.org/models/hotnetsFinal.pdf
]</color></underline>. Just having web-traffic (all with the same
RTTs) does not create a realistic environment as it does not do
anything about RTTs and also flow sizes tend to be highly skewed with
the Pareto distribution-- but I don't know exactly how you  create
your testing environment with web-traffic -- I can only guess from the
description you have about the web traffic in your paper. 


Another puzzle in this difference seems that even under no background
traffic, we also get different results from yours..hmm...especially
with FAST because under no background traffic, FAST seems to work
fairly well with good RTT fairness in our experiment. But your results
show FAST has huge RTT-unfairness. That is very strange. Is that
because we have different bandwidth and buffer sizes in the setup? I
think we need to compare our notes more. Also in the journal paper of
FAST experimental results
[<underline><color><param>0000,0000,FFFF</param>http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf
]</color></underline>, FAST seems to work very well under no
background traffic.  We will verify our results again in the exact
same environment as you have in your report, to make sure we can
reproduce your results....but here are some samples of our results for
FAST.


<underline><color><param>0000,0000,FFFF</param>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200--2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-1000-10-1200-64000-150--1/ 

</color></underline>

In this experiment, FAST flows are just perfect. Also the same result
is confirmed inthe  FAST journal paper
[<underline><color><param>0000,0000,FFFF</param>http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf
-- please look at Section IV.B and C.  But your results show really
bad RTT fairness.]

</color></underline>

Best regards,

Injong


---

Injong Rhee

NCSU




On Sep 22, 2006, at 10:22 AM, Douglas Leith wrote:


<excerpt>For those interested in TCP for high-speed environments, and
perhaps also people interested in TCP evaluation generally, I'd like
to point you towards the results of a detailed experimental study
which are now available at:


http://www.hamilton.ie/net/eval/ToNfinal.pdf


This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP,
FAST-TCP and H-TCP performance under a wide range of conditions
including with mixes of long and short-lived flows.  This study has
now been subject to peer review (to hopefully give it some legitimacy)
and is due to appear in the Transactions on Networking.


The conclusions (see summary below) seem especially topical as BIC-TCP
is currently widely deployed as the default algorithm in Linux.


Comments appreciated.  Our measurements are publicly available - on
the web or drop me a line if you'd like a copy.


Summary:

In this paper we present experimental results evaluating the

performance of the Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and

H-TCP proposals in a series of benchmark tests.


We find that many recent proposals perform surprisingly poorly in

even the most simple test, namely achieving fairness between two

competing flows in a dumbbell topology with the same round-trip

times and shared bottleneck link. Specifically, both Scalable-TCP

and FAST TCP exhibit very substantial unfairness in this test.


We also find that Scalable-TCP, HS-TCP and BIC-TCP induce
significantly greater RTT unfairness between competing flows with
different round-trip times.  The unfairness can be an order of
magnitude greater than that with standard TCP and is such that flows
with longer round-trip times

can be completely starved of bandwidth.


While the TCP proposals studied are all successful at improving

the link utilisation in a relatively static environment with

long-lived flows, in our tests many of the proposals exhibit poor

responsiveness to changing network conditions.  We observe that

Scalable-TCP, HS-TCP and BIC-TCP can all suffer from extremely

slow (>100s) convergence times following the startup of a new

flow. We also observe that while FAST-TCP flows typically converge

quickly initially, flows may later diverge again to create

significant and sustained unfairness.


--Doug


Hamilton Institute

www.hamilton.ie



</excerpt>
--Apple-Mail-13-280100244--
