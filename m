From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Re: performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Fri, 22 Sep 2006 22:34:08 -0400
Message-ID: <001b01c6deb8$c0375bc0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0018_01C6DE97.380A1290"
Cc: netdev@vger.kernel.org, floyd@ICSI.Berkeley.EDU, lisongxu@gmail.com,
        end2end-interest@postel.org
Return-path: <end2end-interest-bounces@postel.org>
To: <doug.leith@nuim.ie>
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

This is a multi-part message in MIME format.

------=_NextPart_000_0018_01C6DE97.380A1290
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: quoted-printable

This is a resend with fixed web links. The links were broken in my =
previous email -- sorry about multiple transmissions.

-------------------------------------------------------------------------=
--------

Hi Doug,


Thanks for sharing your paper. Also congratulations to the acceptance of =
your journal paper to TONs. But I am wondering what's new in this paper. =
At first glance, I did not find many new things that are different from =
your previously publicized reports. How much is this different from the =
ones you put out in this mail list a year or two ago and also the one =
publicized in PFLDnet February this year =
http://www.hpcc.jp/pfldnet2006/? In that same workshop, we also =
presented our experimental results that shows significant discrepancy =
from yours but i am not sure why you forgot to reference our =
experimental work presented in that same PFLDnet. Here is a link to a =
more detailed version of that report accepted to COMNET =
http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf


The main point of contention [that we talked about in that PFLDnet =
workshop] is the presence of background traffic and the method to add =
them. Your report mostly ignores the effect of background traffic. Some =
texts in this paper state that you added some web traffic (10%), but the =
paper shows only the results from NO background traffic scenarios. But =
our results differ from yours in many aspects. Below are the links to =
our results (the links to them have been available in our BIC web site =
for a long time and also mentioned in our PFLDnet paper; this result is =
with the patch that corrects HTCP bugs).=20


[Convergence and intra protocol fairness]=20

without background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/intra_proto=
col.htm



with background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra_protoco=
l.htm


[RTT fairness]:=20

w/o background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_fairness.=
htm

with background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fairness.ht=
m


[TCP friendliness]

without background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/tcp_frien=
dliness.htm

with background traffic: =
http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp_friendl=
iness.htm


After our discussion in that PFLDnet, I puzzled why we get different =
results. My guess is that the main difference between your experiment =
and ours is the inclusion of mid-sized flows with various RTTs -- our =
experience tells that the RTT variations of mid size flows play a very =
important role in creating significant dynamics in testing environments. =
The same point about the importance of mid size flows with RTT =
variations has been raised in several occasions by Sally Floyd as well, =
including in this year's E2E research group meeting. You can find some =
reference to the importance of RTT variations in her paper too [ =
http://www.icir.org/models/hotnetsFinal.pdf]. Just having web-traffic =
(all with the same RTTs) does not create a realistic environment as it =
does not do anything about RTTs and also flow sizes tend to be highly =
skewed with the Pareto distribution-- but I don't know exactly how you =
create your testing environment with web-traffic -- I can only guess =
from the description you have about the web traffic in your paper.=20


Another puzzle in this difference seems that even under no background =
traffic, we also get different results from yours..hmm...especially with =
FAST because under no background traffic, FAST seems to work fairly well =
with good RTT fairness in our experiment. But your results show FAST has =
huge RTT-unfairness. That is very strange. Is that because we have =
different bandwidth and buffer sizes in the setup? I think we need to =
compare our notes more. Also in the journal paper of FAST experimental =
results [ =
http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf ], =
FAST seems to work very well under no background traffic. We will verify =
our results again in the exact same environment as you have in your =
report, to make sure we can reproduce your results....but here are some =
samples of our results for FAST.=20


http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200--2.4_FAS=
T-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-1000-10-12=
00-64000-150--1/


In this experiment, FAST flows are just perfect. Also the same result is =
confirmed inthe FAST journal paper [ =
http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007.pdf-- =
please look at Section IV.B and C. But your results show really bad RTT =
fairness.]


Best regards,

Injong


---

Injong Rhee

NCSU




On Sep 22, 2006, at 10:22 AM, Douglas Leith wrote:

For those interested in TCP for high-speed environments, and perhaps =
also people interested in TCP evaluation generally, I'd like to point =
you towards the results of a detailed experimental study which are now =
available at:=20



http://www.hamilton.ie/net/eval/ToNfinal.pdf=20



This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP =
and H-TCP performance under a wide range of conditions including with =
mixes of long and short-lived flows. This study has now been subject to =
peer review (to hopefully give it some legitimacy) and is due to appear =
in the Transactions on Networking.=20



The conclusions (see summary below) seem especially topical as BIC-TCP =
is currently widely deployed as the default algorithm in Linux.=20



Comments appreciated. Our measurements are publicly available - on the =
web or drop me a line if you'd like a copy.



Summary:

In this paper we present experimental results evaluating the

performance of the Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and

H-TCP proposals in a series of benchmark tests.



We find that many recent proposals perform surprisingly poorly in

even the most simple test, namely achieving fairness between two

competing flows in a dumbbell topology with the same round-trip

times and shared bottleneck link. Specifically, both Scalable-TCP

and FAST TCP exhibit very substantial unfairness in this test.



We also find that Scalable-TCP, HS-TCP and BIC-TCP induce significantly =
greater RTT unfairness between competing flows with different round-trip =
times. The unfairness can be an order of magnitude greater than that =
with standard TCP and is such that flows with longer round-trip times=20

can be completely starved of bandwidth.



While the TCP proposals studied are all successful at improving

the link utilisation in a relatively static environment with

long-lived flows, in our tests many of the proposals exhibit poor

responsiveness to changing network conditions. We observe that

Scalable-TCP, HS-TCP and BIC-TCP can all suffer from extremely

slow (>100s) convergence times following the startup of a new

flow. We also observe that while FAST-TCP flows typically converge

quickly initially, flows may later diverge again to create

significant and sustained unfairness.



--Doug



Hamilton Institute

www.hamilton.ie

------=_NextPart_000_0018_01C6DE97.380A1290
Content-Type: text/html;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dks_c_5601-1987">
<META content=3D"MSHTML 6.00.2900.2963" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">This=20
is a resend with fixed web links. The links were broken in my previous =
email --=20
sorry about multiple transmissions.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: =
10pt">-------------------------------------------------------------------=
--------------</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">Hi=20
Doug,</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Thanks for sharing your paper. Also =
congratulations to=20
the acceptance of your journal paper to TONs. But I am wondering what's =
new in=20
this paper. At first glance, I did not find many new things that are =
different=20
from your previously publicized reports. How much is this different from =
the=20
ones you put out in this mail list a year or two ago and also the one =
publicized=20
in PFLDnet February this year <A title=3Dhttp://www.hpcc.jp/pfldnet2006/ =

onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://www.hpcc.jp/pfldnet2006/"=20
target=3D_blank>http://www.hpcc.jp/pfldnet2006/</A>? In that same =
workshop, we=20
also presented our experimental results that shows significant =
discrepancy from=20
yours but i am not sure why you forgot to reference our experimental =
work=20
presented in that same PFLDnet. Here is a link to a more detailed =
version of=20
that report accepted to COMNET <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pdf"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/comnet-asteppaper.pd=
f</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">The=20
main point of contention [that we talked about in that PFLDnet workshop] =
is the=20
presence of background traffic and the method to add them. Your report =
mostly=20
ignores the effect of background traffic. Some texts in this paper state =
that=20
you added some web traffic (10%), but the paper shows only the results =
from NO=20
background traffic scenarios. But our results differ from yours in many =
aspects.=20
Below are the links to our results (the links to them have been =
available in our=20
BIC web site for a long time and also mentioned in our PFLDnet paper; =
this=20
result is with the patch that corrects HTCP bugs). </SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">[Convergence and intra protocol fairness]=20
</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT><FONT face=3D"Courier New" =
size=3D2><SPAN=20
lang=3DEN-US style=3D"FONT-SIZE: 10pt">without background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/int=
ra_protocol.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_protocol/int=
ra_protocol.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/intra_prot=
ocol/intra_protocol.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">with=20
background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra=
_protocol.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protocol/intra=
_protocol.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/bk/intra_protoc=
ol/intra_protocol.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">[RTT=20
fairness]: </SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">w/o=20
background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_f=
airness.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/rtt_f=
airness.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairne=
ss/rtt_fairness.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">with=20
background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fai=
rness.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness/rtt_fai=
rness.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/bk/rtt_fairness=
/rtt_fairness.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">[TCP=20
friendliness]</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">without background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/t=
cp_friendliness.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friendliness/t=
cp_friendliness.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/tcp_friend=
liness/tcp_friendliness.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">with=20
background traffic: <A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp=
_friendliness.htm=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendliness/tcp=
_friendliness.htm"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/bk/tcp_friendli=
ness/tcp_friendliness.htm</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">After our discussion in that PFLDnet, I =
puzzled why we=20
get different results. My guess is that the main difference between your =

experiment and ours is the inclusion of mid-sized flows with various =
RTTs -- our=20
experience tells that the RTT variations of mid size flows play a very =
important=20
role in creating significant dynamics in testing environments. The same =
point=20
about the importance of mid size flows with RTT variations has been =
raised in=20
several occasions by Sally Floyd as well, including in this year's E2E =
research=20
group meeting. You can find some reference to the importance of RTT =
variations=20
in her paper too [ <A =
title=3Dhttp://www.icir.org/models/hotnetsFinal.pdf=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://www.icir.org/models/hotnetsFinal.pdf"=20
target=3D_blank>http://www.icir.org/models/hotnetsFinal.pdf</A>]. Just =
having=20
web-traffic (all with the same RTTs) does not create a realistic =
environment as=20
it does not do anything about RTTs and also flow sizes tend to be highly =
skewed=20
with the Pareto distribution-- but I don't know exactly how you create =
your=20
testing environment with web-traffic -- I can only guess from the =
description=20
you have about the web traffic in your paper. </SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Another puzzle in this difference seems that =
even under=20
no background traffic, we also get different results from=20
yours..hmm...especially with FAST because under no background traffic, =
FAST=20
seems to work fairly well with good RTT fairness in our experiment. But =
your=20
results show FAST has huge RTT-unfairness. That is very strange. Is that =
because=20
we have different bandwidth and buffer sizes in the setup? I think we =
need to=20
compare our notes more. Also in the journal paper of FAST experimental =
results [=20
<A =
title=3Dhttp://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007=
.pdf=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007=
.pdf"=20
target=3D_blank>http://netlab.caltech.edu/publications/FAST-ToN-final-060=
209-2007.pdf</A>=20
], FAST seems to work very well under no background traffic. We will =
verify our=20
results again in the exact same environment as you have in your report, =
to make=20
sure we can reproduce your results....but here are some samples of our =
results=20
for FAST. </SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt"><A=20
title=3Dhttp://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200-=
-2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-10=
00-10-1200-64000-150--1/=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairness/1200-=
-2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--200000-0.6-10=
00-10-1200-64000-150--1/"=20
target=3D_blank>http://netsrv.csc.ncsu.edu/highspeed/1200/nobk/rtt_fairne=
ss/1200--2.4_FAST-2.4_FAST-NONE--400-3-1333--1000-76-3-0-0-0-5-500--20000=
0-0.6-1000-10-1200-64000-150--1/</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">In=20
this experiment, FAST flows are just perfect. Also the same result is =
confirmed=20
inthe FAST journal paper [ <A=20
title=3Dhttp://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007=
.pdf=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://netlab.caltech.edu/publications/FAST-ToN-final-060209-2007=
.pdf"=20
target=3D_blank>http://netlab.caltech.edu/publications/FAST-ToN-final-060=
209-2007.pdf</A></SPAN></FONT><FONT=20
face=3D"Courier New" size=3D2><SPAN lang=3DEN-US style=3D"FONT-SIZE: =
10pt">-- please=20
look at Section IV.B and C. But your results show really bad RTT=20
fairness.]</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">Best=20
regards,</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Injong</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">---</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Injong Rhee</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">NCSU</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">On=20
Sep 22, 2006, at 10:22 AM, Douglas Leith wrote:</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">For=20
those interested in TCP for high-speed environments, and perhaps also =
people=20
interested in TCP evaluation generally, I'd like to point you towards =
the=20
results of a detailed experimental study which are now available at:=20
</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt"><A=20
title=3Dhttp://www.hamilton.ie/net/eval/ToNfinal.pdf=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://www.hamilton.ie/net/eval/ToNfinal.pdf"=20
target=3D_blank>http://www.hamilton.ie/net/eval/ToNfinal.pdf=20
</A></SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">This=20
study consistently compares Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP and =
H-TCP=20
performance under a wide range of conditions including with mixes of =
long and=20
short-lived flows. This study has now been subject to peer review (to =
hopefully=20
give it some legitimacy) and is due to appear in the Transactions on =
Networking.=20
</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">The=20
conclusions (see summary below) seem especially topical as BIC-TCP is =
currently=20
widely deployed as the default algorithm in Linux.</SPAN> </FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Comments appreciated. Our measurements are =
publicly=20
available - on the web or drop me a line if you'd like a =
copy.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Summary:</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">In=20
this paper we present experimental results evaluating =
the</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">performance of the Scalable-TCP, HS-TCP, =
BIC-TCP,=20
FAST-TCP and</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">H-TCP proposals in a series of benchmark=20
tests.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">We=20
find that many recent proposals perform surprisingly poorly =
in</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">even=20
the most simple test, namely achieving fairness between =
two</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">competing flows in a dumbbell topology with =
the same=20
round-trip</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">times and shared bottleneck link. =
Specifically, both=20
Scalable-TCP</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">and=20
FAST TCP exhibit very substantial unfairness in this =
test.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">We=20
also find that Scalable-TCP, HS-TCP and BIC-TCP induce significantly =
greater RTT=20
unfairness between competing flows with different round-trip times. The=20
unfairness can be an order of magnitude greater than that with standard =
TCP and=20
is such that flows with longer round-trip times </SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">can=20
be completely starved of bandwidth.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">While the TCP proposals studied are all =
successful at=20
improving</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">the=20
link utilisation in a relatively static environment =
with</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">long-lived flows, in our tests many of the =
proposals=20
exhibit poor</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">responsiveness to changing network conditions. =
We=20
observe that</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Scalable-TCP, HS-TCP and BIC-TCP can all =
suffer from=20
extremely</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt">slow=20
(&gt;100s) convergence times following the startup of a =
new</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">flow. We also observe that while FAST-TCP =
flows=20
typically converge</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">quickly initially, flows may later diverge =
again to=20
create</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">significant and sustained =
unfairness.</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">--Doug</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt"></SPAN></FONT>&nbsp;</P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US=20
style=3D"FONT-SIZE: 10pt">Hamilton Institute</SPAN></FONT></P>
<P><FONT face=3D"Courier New" size=3D2><SPAN lang=3DEN-US =
style=3D"FONT-SIZE: 10pt"><A=20
title=3Dhttp://www.hamilton.ie/=20
onclick=3D"return top.js.OpenExtLink(window,event,this)"=20
href=3D"http://www.hamilton.ie/"=20
target=3D_blank>www.hamilton.ie</A></SPAN></FONT></P></FONT></DIV></BODY>=
</HTML>

------=_NextPart_000_0018_01C6DE97.380A1290--
