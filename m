From: Albert Cahalan <acahalan@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 18:33:39 -0500
Message-ID: <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
	<AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	<20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 27, 2011 at 5:55 AM, Jussi Kivilinna
<jussi.kivilinna@mbnet.fi> wrote:

> I made simple hack on sch_fifo with per packet time limits (attachment) this
> weekend and have been doing limited testing on wireless link. I think
> hardlimit is fine, it's simple and does somewhat same as what
> packet(-hard)limited buffer does, drops packets when buffer is 'full'. My
> hack checks for timed out packets on enqueue, might be wrong approach (on
> other hand might allow some more burstiness).

Thanks!

I think the default is too high. 1 ms may even be a bit high.

I suppose there is a need to allow at least 2 packets despite any
time limits, so that it remains possible to use a traditional modem
even if a huge packet takes several seconds to send.
