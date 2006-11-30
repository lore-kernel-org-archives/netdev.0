From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 11:51:09 -0500
Message-ID: <1164905470.12607.71.camel@mindpipe>
References: <2f14bf623344.456de60a@fnal.gov>
	 <20061130093329.GA4645@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wenji Wu <wenji@fnal.gov>, David Miller <davem@davemloft.net>,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viper.oldcity.dca.net ([216.158.38.4]:18875 "HELO
	viper.oldcity.dca.net") by vger.kernel.org with SMTP
	id S1759271AbWK3Qug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 11:50:36 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061130093329.GA4645@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 09:33 +0000, Christoph Hellwig wrote:
> On Wed, Nov 29, 2006 at 07:56:58PM -0600, Wenji Wu wrote:
> > Yes, when CONFIG_PREEMPT is disabled, the "problem" won't happen. That is why I put "for 2.6 desktop, low-latency desktop" in the uploaded paper. This "problem" happens in the 2.6 Desktop and Low-latency Desktop.
> 
> CONFIG_PREEMPT is only for people that are in for the feeling.  There is no
> real world advtantage to it and we should probably remove it again.

There certainly is a real world advantage for many applications.  Of
course it would be better if the latency requirements could be met
without kernel preemption but that's not the case now.

Lee

