From: David Miller <davem@davemloft.net>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 20:18:52 -0800 (PST)
Message-ID: <20110228.201852.193726064.davem@davemloft.net>
References: <20110228165501.GC2515@tuxdriver.com>
	<AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	<AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, linville@tuxdriver.com,
	eric.dumazet@gmail.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acahalan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Albert Cahalan <acahalan@gmail.com>
Date: Mon, 28 Feb 2011 23:11:13 -0500

> It sounds like you need a callback or similar, so that TCP can be
> informed later that the drop has occurred.

By that point we could have already sent an entire RTT's worth
of data, or more.

It needs to be synchronous, otherwise performance suffers.
