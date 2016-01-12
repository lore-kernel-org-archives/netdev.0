From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dwc_eth_qos: Fix dma address for multi-fragment
 skbs
Date: Tue, 12 Jan 2016 15:32:15 -0500 (EST)
Message-ID: <20160112.153215.2154508309972980462.davem@davemloft.net>
References: <1452608893-19126-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	larper@axis.com
To: lars.persson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452608893-19126-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson@axis.com>
Date: Tue, 12 Jan 2016 15:28:13 +0100

> The offset inside the fragment was not used for the dma address and
> silent data corruption resulted because TSO makes the checksum match.
> 
> Fixes: 077742dac2c7 ("dwc_eth_qos: Add support for Synopsys DWC Ethernet QoS")
> Signed-off-by: Lars Persson <larper@axis.com>

Applied and queued up for -stable, thanks.
