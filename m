From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibm/emac: fix improper cleanup when device is
 removed to allow re-bind
Date: Thu, 17 Nov 2011 17:05:26 -0500 (EST)
Message-ID: <20111117.170526.1920810007806589605.davem@davemloft.net>
References: <4EC506E4.5060806@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, Linuxppc-dev@lists.ozlabs.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4EC506E4.5060806@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 17 Nov 2011 14:06:44 +0100

> The re-binding (unbind..bind) of an EMAC device fails because the
> static variable "busy_phy_map" is not updated when the device is
> removed.
> 
> Signed-off-by: Wolfgang Grandegger <wg@denx.de>

Applied, thanks.
