From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPROUTE 02/05]: Introduce tc_calc_xmitsize and use where appropriate
Date: Mon, 15 Jan 2007 13:35:18 +0100
Message-ID: <20070115123518.GA3124@ff.dom.local>
References: <20070110100146.29356.23184.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:47409 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932281AbXAOMdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 07:33:12 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20070110100146.29356.23184.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10-01-2007 11:01, Patrick McHardy wrote:
> [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
> 
> Add tc_calc_xmitsize() as complement to tc_calc_xmittime(), which calculates
> the size that can be transmitted at a given rate during a given time.
> 
> Replace all expressions of the form "size = rate*tc_core_tick2usec(time))/1000000"
> by tc_calc_xmitsize() calls.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
...
> +unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
> +{
> +	return ((double)rate*tc_core_tick2usec(ticks))/1000000;
> +}
> +

Actually, besides of replacing the expression, this function
changes its type to unsigned also.

Regards,
Jarek P. 
