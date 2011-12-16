From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/6] tg3: adaptive interrupt coalescing,
 non-napi mode
Date: Fri, 16 Dec 2011 13:42:47 -0500 (EST)
Message-ID: <20111216.134247.1388025459559232416.davem@davemloft.net>
References: <cover.1324059527.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, martinez.javier@gmail.com,
	rgetz@blackfin.uclinux.org, mpm@selenic.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Fri, 16 Dec 2011 10:19:43 -0800

> This series implements adaptive interrupt coalescing for tg3 NIC,
> improving performance substancially. It also implements non-NAPI mode
> for specific system loads.

I specifically removed the dynamic IRQ coalescing from this driver years
ago.

It's too susceptible to state changes.

I am sure that you have some nice benchmark for which one scheme helps,
but more generally it is not possible to make it such that you will avoid
the case where the network flow pattern changes by the time you change
the chip configuration and thus the result is suboptimal.

I highly recommend these changes are not applied, because they will hurt
someone.
