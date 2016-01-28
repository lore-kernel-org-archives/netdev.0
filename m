From: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Subject: Re: [PATCH] net: mv643xx_eth: fix packet corruption with TSO and tiny
 unaligned packets.
Date: Thu, 28 Jan 2016 22:12:08 +0100
Message-ID: <56AA8428.2060706@familie-kirchhofer.de>
References: <1453821155-27561-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
To: Nicolas Schichan <nschichan@freebox.fr>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453821155-27561-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 26.01.2016 um 16:12 schrieb Nicolas Schichan:
> The code in txq_put_data() would use txq->tx_curr_desc to index the
> tso_hdrs/tso_hdrs_dma buffers, for less than 8 bytes unaligned
> fragments, which is already moved to the next descriptor at the
> beginning of the function.
>
> If that fragment was the last of the the skb, the next skb would use
> that same space to place the ip headers, overwritting that small
> fragment data.
>
> Fixes: 91986fd3d335 (net: mv643xx_eth: Ensure proper data alignment in TSO TX path)
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

Hello Nicolas,

thanks for catching this bug. Fix is good.

Reviewed-by: Philipp Kirchhofer <philipp@familie-kirchhofer.de>

Best wishes,
   Philipp
