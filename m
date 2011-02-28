From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 11:11:15 -0500
Message-ID: <20110228161115.GB2515@tuxdriver.com>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
 <1298837273.8726.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1298837273.8726.128.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 27, 2011 at 09:07:53PM +0100, Eric Dumazet wrote:

> Qdisc should return to caller a good indication packet is queued or
> dropped at enqueue() time... not later (aka : never)
> 
> Accepting a packet at t0, and dropping it later at t0+limit without
> giving any indication to caller is a problem.

Can you elaborate on what problem this causes?  Is it any worse than
if the packet is dropped at some later hop?

Is there any API that could report the drop to the sender (at
least a local one) without having to wait for the ack timeout?
Should there be?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
