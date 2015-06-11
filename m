From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] tcp: add CDG congestion control
Date: Thu, 11 Jun 2015 00:09:36 -0700 (PDT)
Message-ID: <20150611.000936.1284222338637719486.davem@davemloft.net>
References: <1433956097-6186-1-git-send-email-kennetkl@ifi.uio.no>
	<1433956097-6186-2-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	stephen@networkplumber.org, ncardwell@google.com,
	davihay@ifi.uio.no, apetlund@simula.no, dave.taht@bufferbloat.net,
	nicolas.kuhn@telecom-bretagne.eu
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbbFKHJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:09:37 -0400
In-Reply-To: <1433956097-6186-2-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Wed, 10 Jun 2015 19:08:17 +0200

> CAIA Delay-Gradient (CDG) is a TCP congestion control that modifies
> the TCP sender in order to [1]:
> 
>   o Use the delay gradient as a congestion signal.
>   o Back off with an average probability that is independent of the RTT.
>   o Coexist with flows that use loss-based congestion control, i.e.,
>     flows that are unresponsive to the delay signal.
>   o Tolerate packet loss unrelated to congestion. (Disabled by default.)
> 
> Its FreeBSD implementation was presented for the ICCRG in July 2012;
> slides are available at http://www.ietf.org/proceedings/84/iccrg.html
> 
> Running the experiment scenarios in [1] suggests that our implementation
> achieves more goodput compared with FreeBSD 10.0 senders, although it also
> causes more queueing delay for a given backoff factor.
> 
> The loss tolerance heuristic is disabled by default due to safety concerns
> for its use in the Internet [2, p. 45-46].
> 
> We use a variant of the Hybrid Slow start algorithm in tcp_cubic to reduce
> the probability of slow start overshoot.
> 
> [1] D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
>     delay gradients." In Networking 2011, pages 328-341. Springer, 2011.
> [2] K.K. Jonassen. "Implementing CAIA Delay-Gradient in Linux."
>     MSc thesis. Department of Informatics, University of Oslo, 2015.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: David Hayes <davihay@ifi.uio.no>
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Applied.
