From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] bnx2x: Fan failure mechanism on additional design
Date: Mon, 25 Aug 2008 15:22:19 -0700 (PDT)
Message-ID: <20080825.152219.126861451.davem@davemloft.net>
References: <1219674270.19456.28.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52487
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753507AbYHYWWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:22:22 -0400
In-Reply-To: <1219674270.19456.28.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:24:30 +0300

> The A1021G board is also using the fan failure mechanism in the same way
> the A1022G board does
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, but please fix something up:

> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 272f5d1..2e207b8 100755
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c

I keep seeing patches from Broadcom with execute permissions being
added to the source files.

The correct permission in the diff should show up as "100644"
instead of "100755".

Please clear the execute permission for these source files in
the GIT tree(s) you are using.

Thank you.
