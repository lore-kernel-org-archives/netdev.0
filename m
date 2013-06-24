From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: fix misreporting of transmit abort
Date: Mon, 24 Jun 2013 00:10:52 -0700 (PDT)
Message-ID: <20130624.001052.717125614529984964.davem@davemloft.net>
References: <201306210113.43087.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306210113.43087.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 21 Jun 2013 01:13:42 +0400

> Due to obviously missing braces, EESR.TABT (transmit abort) interrupt may be
> reported even if it hasn't happened, just when EESR.TWB (transmit descriptor
> write-back) interrupt happens. Luckily (?), EESR.TWB is disabled by the driver
> via the TRIMD register and all the interrupt masks, so that transmit abort is
> never actually logged...
> 
> Put the braces where they should be and fix the incoherent comment, while at it. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Also applied to 'net'.
