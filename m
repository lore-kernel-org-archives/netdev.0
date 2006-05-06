From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Re: a question on tcp_highspeed.c (in 2.6.16)
Date: Fri, 05 May 2006 17:42:03 -0700 (PDT)
Message-ID: <20060505.174203.40998208.davem@davemloft.net>
References: <7335583a0605040703x1d6e8a20n515b22241795d3ab@mail.gmail.com>
	<445A5098.6010306@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidwei79@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12438
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751617AbWEFAmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:42:04 -0400
To: jheffner@psc.edu
In-Reply-To: <445A5098.6010306@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 04 May 2006 15:06:00 -0400

> Xiaoliang (David) Wei wrote:
> > Hi gurus,
> > 
> >    I am reading the code of tcp_highspeed.c in the kernel and have a
> > question on the hstcp_cong_avoid function, specifically the following
> > AI part (line 136~143 in net/ipv4/tcp_highspeed.c ):
> > 
> >                /* Do additive increase */
> >                if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
> >                        tp->snd_cwnd_cnt += ca->ai;
> >                        if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
> >                                tp->snd_cwnd++;
> >                                tp->snd_cwnd_cnt -= tp->snd_cwnd;
> >                        }
> >                }
> > 
> >    In this part, when (tp->snd_cwnd_cnt == tp->snd_cwnd),
> > snd_cwnd_cnt will be -1... snd_cwnd_cnt is defined as u16, will this
> > small chance of getting -1 becomes a problem?
> > Shall we change it by reversing the order of the cwnd++ and cwnd_cnt -= 
> > cwnd?
> 
> Absolutely correct.  Thanks.
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Applied, thanks a lot everyone.
