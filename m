From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next v2 3/3] gianfar: Implement PAUSE frame generation
 support
Date: Thu, 23 Oct 2014 12:36:55 +0300
Message-ID: <5448CC37.6040300@freescale.com>
References: <1414055930-10331-1-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Matei Pavaluca <matei.pavaluca@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0109.outbound.protection.outlook.com ([207.46.100.109]:7639
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750799AbaJWJhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 05:37:06 -0400
In-Reply-To: <1414055930-10331-1-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 12:18 PM, Matei Pavaluca wrote:
> The hardware can automatically generate pause frames when the number
> of free buffers drops under a certain threshold, but in order to do this,
> the address of the last free buffer needs to be written to a specific
> register for each RX queue.
>
> This has to be done in 'gfar_clean_rx_ring' which is called for each
> RX queue. In order not to impact performance, by adding a register write
> for each incoming packet, this operation is done only when the PAUSE frame
> transmission is enabled.
>
> Whenever the link is readjusted, this capability is turned on or off.
>
> Signed-off-by: Matei Pavaluca <matei.pavaluca@freescale.com>
> ---
>
> v2:
>    - Added unlikely() in 'gfar_clean_rx_ring'
>    - Removed some unused variables

Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
