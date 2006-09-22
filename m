From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 05:42:59 +1200
Message-ID: <5640c7e00609221042w5122c37cm7db3013e21e3b5dc@mail.gmail.com>
References: <4513F1A1.3000506@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: end2end-interest@postel.org, netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.234]:27220 "EHLO
	qb-out-0506.google.com") by vger.kernel.org with ESMTP
	id S964822AbWIVRnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 13:43:01 -0400
Received: by qb-out-0506.google.com with SMTP id p36so78455qba
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 10:43:00 -0700 (PDT)
To: "Douglas Leith" <doug.leith@nuim.ie>
In-Reply-To: <4513F1A1.3000506@nuim.ie>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/23/06, Douglas Leith <doug.leith@nuim.ie> wrote:
> For those interested in TCP for high-speed environments, and perhaps
> also people interested in TCP evaluation generally, I'd like to point
> you towards the results of a detailed experimental study which are now
> available at:
>
> http://www.hamilton.ie/net/eval/ToNfinal.pdf
>
> This study consistently compares Scalable-TCP, HS-TCP, BIC-TCP, FAST-TCP
> and H-TCP performance under a wide range of conditions including with
> mixes of long and short-lived flows.  This study has now been subject to
> peer review (to hopefully give it some legitimacy) and is due to appear
> in the Transactions on Networking.
>
> The conclusions (see summary below) seem especially topical as BIC-TCP
> is currently widely deployed as the default algorithm in Linux.
>
> Comments appreciated.  Our measurements are publicly available - on the
> web or drop me a line if you'd like a copy.
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
> We also find that Scalable-TCP, HS-TCP and BIC-TCP induce significantly
> greater RTT unfairness between competing flows with different round-trip
> times.  The unfairness can be an order of magnitude greater than that
> with standard TCP and is such that flows with longer round-trip times
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
>
Interesting reading and I am replying to netdev@vger.kernel.org as
well. I will read in more detail later but my first questions/comments
are:
- have you tested CUBIC subsequently as this is meant to fix many of
the rtt issues? This is becoming the default in 2.6.19 probably.
- have you tested subsequently on more recent kernels than 2.6.6?

Looks like some very useful information.

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
