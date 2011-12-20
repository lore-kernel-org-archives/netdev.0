From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH] stmmac: reduce queue lengths if MTU is very large
Date: Tue, 20 Dec 2011 08:30:50 +0100
Message-ID: <20111220073050.GA2817@mail.gnudd.com>
References: <20111219.163337.1185514300243434827.davem@davemloft.net>
  <1324273530-18499-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	giancarlo.asnaghi@st.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.gnudd.com ([213.203.150.91]:61339 "EHLO mail.gnudd.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753036Ab1LTHbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 02:31:03 -0500
Content-Disposition: inline
In-Reply-To: <20111219.163337.1185514300243434827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This change doesn't make sense.

I disagree, but you are the boss here, so I accept that.

> I'm not applying this, it just points out that the amount of reserved
> space in your SWIOMMU setup might be insufficient for this situation
> rather than something that should be tweaked in this driver.

Allocation of the queues is based on a parameter. If the parameter was
a size, instead of a lenght, all would be fine, wouldn't it? If you
agree, then this patch is turning the lenght into a size, in a way.

Now, how could we deal with the fact that the size explodes if the MTU
is increased?  I don't want to reserve and waste 16MB of RAM for a
single device: the device won't even use them for non-jumbo setups.  I
can use the parameter to shorten the queue in all cases, but this is
not good either.

What's your suggestion?

thanks
/alessandro
