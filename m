From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/7] caif: Disconnect without waiting for
 response
Date: Wed, 28 Apr 2010 13:03:15 -0700 (PDT)
Message-ID: <20100428.130315.258136544.davem@davemloft.net>
References: <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109Ab0D1UDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:03:10 -0400
In-Reply-To: <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Wed, 28 Apr 2010 20:54:37 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Changes:
> o Function cfcnfg_disconn_adapt_layer is changed to do asynchronous
>   disconnect, not waiting for any response from the modem. Due to this
>   the function cfcnfg_linkdestroy_rsp does nothing anymore.
> o Because disconnect may take down a connection before a connect response
>   is received the function cfcnfg_linkup_rsp is checking if the client is
>   still waiting for the response, if not a disconnect request is sent to
>   the modem.
> o cfctrl is no longer keeping track of pending disconnect requests.
> o Added function cfctrl_cancel_req, which is used for deleting a pending
>   connect request if disconnect is done before connect response is received.
> o Removed unused function cfctrl_insert_req2
> o Added better handling of connect reject from modem.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
