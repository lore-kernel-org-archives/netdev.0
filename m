From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Fix different hardware statistics versions.
Date: Sun, 25 Jul 2010 21:54:38 -0700 (PDT)
Message-ID: <20100725.215438.189694767.davem@davemloft.net>
References: <20100722220252.E46C7182B00@starthinker.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com, shemminger@vyatta.com,
	ben@decadent.org.uk, stas@lvk.cs.msu.su,
	linux-kernel@vger.kernel.org
To: mditto@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100722220252.E46C7182B00@starthinker.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mditto@google.com (Mike Ditto)
Date: Thu, 22 Jul 2010 15:02:52 -0700 (PDT)

> The macros for the values of the bit field describing the four
> different versions of statistics supported by different hardware
> variants were being misused.  Where the code was trying to test if the
> hardware implements V3, it was actually testing whether it implements
> any of V1, V2, or V3, causing the driver to report statistics that
> don't really exist in the hardware, with bogus values.
> 
> Signed-off-by: Mike Ditto <mditto@google.com>

Applied to net-next-2.6, thanks.
