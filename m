From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cleanup of cwnd initialization in
 tcp_init_metrics()
Date: Thu, 23 Dec 2010 09:56:15 -0800 (PST)
Message-ID: <20101223.095615.39194231.davem@davemloft.net>
References: <alpine.LNX.2.00.1012231002310.16569@pobox.suse.cz>
	<1293095663.7789.3.camel@edumazet-laptop>
	<alpine.LNX.2.00.1012231022430.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vojtech@suse.cz,
	ilpo.jarvinen@helsinki.fi
To: jkosina@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012231022430.16569@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Thu, 23 Dec 2010 10:23:38 +0100 (CET)

> Right, that's even better. Updated patch below.
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] tcp: cleanup of cwnd initialization in tcp_init_metrics()
> 
> Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case
> when congestion window initialization has been mistakenly omitted
> by introducing cwnd label and putting backwards goto from the
> end of the function.
> 
> This makes the code unnecessarily tricky to read and understand
> on a first sight.
> 
> Shuffle the code around a little bit to make it more obvious.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Applied, thanks everyone.
