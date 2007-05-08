From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skge vs sk98lin
Date: Tue, 8 May 2007 10:15:18 -0700
Message-ID: <20070508101518.288d202a@freekitty>
References: <20070508120034.GB1785@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Stone <mstone@mathom.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36333 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966134AbXEHRPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 13:15:23 -0400
In-Reply-To: <20070508120034.GB1785@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 08 May 2007 08:00:36 -0400
Michael Stone <mstone@mathom.us> wrote:

> 2.6.21 seems to have fixed the stability issues I was seeing when using 
> the skge driver with the older sk98xx dual port fiber cards. There is 
> still one more lingering oddness: if I have *two* dual port cards in a 
> system, say eth2-5, I see traffic on eth2, eth3, and eth5, but nothing 
> on eth4. This seems to be consistent accross a couple of systems I've 
> tested; only the first card's second interface sees packets (e.g., with 
> tcpdump). If I reboot with the sk98lin driver on the same kernel I see 
> all traffic, as expected.
> 
> Mike Stone

Are the statistics changing? ie. ethtool -S eth4 and ifconfig eth4


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
