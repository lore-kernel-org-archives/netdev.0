From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/4][RFC] lro: Kconfig and Makefile
Date: Mon, 30 Jul 2007 17:25:35 +0100
Message-ID: <20070730172535.15993806@oldman.hamilton.local>
References: <200707301724.45781.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41728 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761081AbXG3Qam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 12:30:42 -0400
In-Reply-To: <200707301724.45781.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jul 2007 17:24:45 +0200
Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

> Kconfig and Makefile for LRO
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> ---
>  net/ipv4/Kconfig  |    8 ++++++++
>  net/ipv4/Makefile |    1 +
>  2 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index fb79097..d894f61 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -394,6 +394,14 @@ config INET_XFRM_MODE_BEET
>  
>  	  If unsure, say Y.
>  
> +config INET_LRO
> +	tristate "Large Receive Offload (ipv4/tcp)"
> +
> +	---help---
> +	  Support for Large Receive Offload (ipv4/tcp).
> +
> +	  If unsure, say Y.
> +

Why make this a user selectable option at all? Unless you want
to deal with out of tree drivers (not my problem), it should be hidden
to avoid having to explain an support it.
