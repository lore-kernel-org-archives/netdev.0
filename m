From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] qed: Add firmware 8.20.0.0
Date: Thu, 18 May 2017 11:12:33 -0700
Message-ID: <20170518181233.GU13400@bombadil.infradead.org>
References: <1495021164-7573-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-firmware@kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:33117 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755046AbdERSMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 14:12:34 -0400
Content-Disposition: inline
In-Reply-To: <1495021164-7573-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 02:39:24PM +0300, Yuval Mintz wrote:
> The new QED firmware has 2 main purposes -
> First, it contains fixes to various initializations and firmware
> logic including:
>  - Corrects iSCSI fast retransmit when data digest is enabled.
>  - Stop draining packets when receiving several consecutive PFCs.
>  - Prevent possible assertion when consecutively opening/closing
>    many connections.
>  - Prevent possible asserton due to too long BDQ fetch time.
> 
> In addition, this firmware contains sufficient infrastructure on which
> we'll add iWARP support in our drivers.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> ---
> Hi,
> 
> Please consider applying this to `linux-firmware'.
> 

applied, thanks Yuval.

regards, Kyle
