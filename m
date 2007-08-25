From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] myri10ge: use pcie_get/set_readrq
Date: Sat, 25 Aug 2007 00:41:28 -0400
Message-ID: <46CFB2F8.5000200@garzik.org>
References: <46CE8103.10109@myri.com> <46CE814D.2060704@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42184 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764292AbXHYEla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:41:30 -0400
In-Reply-To: <46CE814D.2060704@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Based on a patch from Peter Oruba, convert myri10ge to use pcie_get_readrq()
> and pcie_set_readrq() instead of our own PCI calls and arithmetics.
> 
> These driver changes incorporate the proposed PCI-X / PCI-Express read byte
> count interface.  Reading and setting those values doesn't take place
> "manually", instead wrapping functions are called to allow quirks for some
> PCI bridges.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off by: Peter Oruba <peter.oruba@amd.com>
> Based on work by Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/net/myri10ge/myri10ge.c |   32 ++++++--------------------------
>  1 file changed, 6 insertions(+), 26 deletions(-)

applied 1-2


