From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 09:33:29 +0000
Message-ID: <20061130093329.GA4645@infradead.org>
References: <2f14bf623344.456de60a@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759229AbWK3Jdf@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Content-Disposition: inline
In-Reply-To: <2f14bf623344.456de60a@fnal.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 07:56:58PM -0600, Wenji Wu wrote:
> Yes, when CONFIG_PREEMPT is disabled, the "problem" won't happen. That is why I put "for 2.6 desktop, low-latency desktop" in the uploaded paper. This "problem" happens in the 2.6 Desktop and Low-latency Desktop.

CONFIG_PREEMPT is only for people that are in for the feeling.  There is no
real world advtantage to it and we should probably remove it again.
