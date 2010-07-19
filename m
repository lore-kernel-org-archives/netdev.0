From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2.6.35-rc3] drivers/net: ks8842 driver
Date: Mon, 19 Jul 2010 15:17:25 -0700
Message-ID: <20100719151725.fc11b40d.akpm@linux-foundation.org>
References: <C43529A246480145B0A6D0234BDB0F0D0212A7@MELANITE.micrel.com>
	<20100713.101434.180417674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Charles.Li@Micrel.Com, horms@verge.net.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45954 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966632Ab0GSWSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:18:04 -0400
In-Reply-To: <20100713.101434.180417674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jul 2010 10:14:34 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David J. Choi <david.choi@micrel.com>
> Date: Tue, 13 Jul 2010 10:09:19 -0700
> Subject: [PATCH] drivers/net: Add Micrel KS8841/42 support to ks8842 driver
> 
> Body of the explanation:
>    -support 16bit and 32bit bus width.
>    -add device reset for ks8842/8841 Micrel device.
>    -set 100Mbps as a default for Micrel device.
>    -set MAC address in both MAC/Switch layer with different sequence for Micrel
>     device, as mentioned in data sheet.
>    -use private data to set options both 16/32bit bus width and Micrel device/
>     Timberdale(FPGA).
>    -update Kconfig in order to put more information about ks8842 device.

gcc says

drivers/net/ks8842.c: In function 'ks8842_handle_rx':
drivers/net/ks8842.c:428: warning: 'status' may be used uninitialized in this function

and I think I agree with it..
