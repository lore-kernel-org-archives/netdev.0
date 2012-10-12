From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mcs7830: Fix link state detection
Date: Fri, 12 Oct 2012 13:59:36 -0400 (EDT)
Message-ID: <20121012.135936.17533537590412761.davem@davemloft.net>
References: <201210121051.42359.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@lisas.de, gregkh@linuxfoundation.org,
	lkml20120218@newton.leun.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201210121051.42359.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Fri, 12 Oct 2012 10:51:41 +0200

> The device had an undocumented "feature": it can provide a sequence of
> spurious link-down status data even if the link is up all the time.
> A sequence of 10 was seen so update the link state only after the device
> reports the same link state 20 times.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> Reported-by: Michael Leun <lkml20120218@newton.leun.net>
> Tested-by: Michael Leun <lkml20120218@newton.leun.net>

Applied.
