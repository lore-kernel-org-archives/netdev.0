From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: remove IRQF_SAMPLE_RANDOM flag
Date: Wed, 22 Feb 2012 14:57:22 -0500 (EST)
Message-ID: <20120222.145722.742265714781636882.davem@davemloft.net>
References: <1329916014.2586.2.camel@offbook>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dave@gnu.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329916014.2586.2.camel@offbook>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davidlohr Bueso <dave@gnu.org>
Date: Wed, 22 Feb 2012 14:06:54 +0100

> From: Davidlohr Bueso <dave@gnu.org>
> 
> This driver is the last user of the IRQF_SAMPLE_RANDOM flag for net drivers, and since add_*_randomness
> interfaces have now deprecated the flag as a source of external noise, we can remove it.
> 
> Signed-off-by: Davidlohr Bueso <dave@gnu.org>

Applied.
