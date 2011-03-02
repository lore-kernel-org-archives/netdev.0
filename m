From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Wed, 02 Mar 2011 14:25:36 -0600
Message-ID: <4D6EA7C0.1020702@genband.com>
References: <20110228165501.GC2515@tuxdriver.com>  <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>  <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>  <20110228.201852.193726064.davem@davemloft.net>  <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com> <1298964381.2676.58.camel@edumazet-laptop> <alpine.DEB.1.10.1103020358010.7942@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Albert Cahalan <acahalan@gmail.com>,
	David Miller <davem@davemloft.net>, johnwheffner@gmail.com,
	linville@tuxdriver.com, jussi.kivilinna@mbnet.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1103020358010.7942@uplift.swm.pp.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2011 09:10 PM, Mikael Abrahamsson wrote:

> For the case when we're ourselves originating the traffic (for instance to 
> a wifi card with varying speed and jitter due to retransmits on the wifi 
> layer), I think it's taking the too easy way out to use the same 
> mechanisms (dropping packets or marking ECN for our own originated packets 
> seems really weird), here we should be able to pushback information to the 
> applications somehow and do prioritization between flows since we're 
> sitting on all information ourselves including the application.

Doesn't the socket tx buffer give all the app pushback necessary?
(Assuming it's set to a sane value.)

We should certainly do prioritization between flows.  Perhaps if no
other information is available the scheduler priority could be used?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
