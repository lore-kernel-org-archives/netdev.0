From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 2 Jul 2003 14:26:56 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200307021426.56138.nf@hipac.org>
References: <Pine.LNX.4.44.0307020826530.23232-100000@netcore.fi>
Reply-To: nf@hipac.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307020826530.23232-100000@netcore.fi>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi Pekka

> Thanks for your clarification.  We've also conducted some tests with
> bridging firewall functionality, and we're very pleased with nf-hipac's
> performance!  Results below.

Great, thanks a lot. Your tests are very interesting for us as we haven't done 
any gigabit or SMP tests yet. 

> In the measurements, tests were run through a bridging Linux firewall,
> with a netperf UDP stream of 1450 byte packets (launched from a different
> computer connected with gigabit ethernet), with a varying amount of
> filtering rules checks for each packet.
> I don't have the specs of the Linux PC hardware handy, but I recall
> they're *very* highend dual-P4's, like 2.4Ghz, very fast PCI bus, etc.

Since real world network traffic always consists of a lot of different sized 
packets taking maximum sized packets is very euphemistic. 1450 byte packets 
at 950 Mbit/s correspond to approx. 80,000 packets/sec.
We are really interested in how our algorithm performs at higher packet rates. 
Our performance tests are based on 100 Mbit hardware so we coudn't test with 
more than approx. 80,000 packets/sec even with minimum sized packets. At this 
packet rate we were hardly able to drive the algorithm to its limit, even 
with more than 25000 rules involved (and our test system was 1.3 GHz 
uniprocessor).

We'd appreciate it very much if you could run additional tests with smaller 
packet sizes (including minimum packet size). This way we can get an idea of 
whether our SMP optimizations work and whether our algorithm in general would 
benefit from further fine tuning.


Regards

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
