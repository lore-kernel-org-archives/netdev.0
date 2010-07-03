From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: resolve statistics issues
Date: Fri, 02 Jul 2010 22:30:05 -0700 (PDT)
Message-ID: <20100702.223005.246533917.davem@davemloft.net>
References: <20100624233230.5864.67401.stgit@leela.lan>
	<20100630005454.GJ21324@exar.com>
	<20100702191349.GD22020@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ramkrishna.Vepa@exar.com,
	Sivakumar.Subramani@exar.com, Sreenivasa.Honnur@exar.com,
	mschmidt@redhat.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752926Ab0GCF3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:29:51 -0400
In-Reply-To: <20100702191349.GD22020@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 2 Jul 2010 14:13:49 -0500

> This patch resolves a number of issues in the statistics gathering of
> the s2io driver.
> 
> On Xframe adapters, the received multicast statistics counter includes
> pause frames which are not indicated to the driver.  This can cause
> issues where the multicast packet count is higher than what has actually
> been received, possibly higher than the number of packets received.
>     
> The driver software counters are replaced with the adapter hardware
> statistics for rx_packets, rx_bytes, and tx_bytes.  It also uses the
> overflow registers to determine if the statistics wrapped the 32bit
> register (removing the window of having a statistic value less than the
> previous call).  rx_length_errors statistic now includes undersized
> packets in addition to oversized packets in its counting.  Finally,
> rx_crc_errors are now being counted.
>     
> Signed-off-by: Jon Mason <jon.mason@exar.com>

Looks good, applied.
