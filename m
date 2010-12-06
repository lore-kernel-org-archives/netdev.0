From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3] be2net: Handle out of buffer
 completions for lancer
Date: Mon, 06 Dec 2010 13:00:03 -0800 (PST)
Message-ID: <20101206.130003.260100159.davem@davemloft.net>
References: <20101201110417.GA1653@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753281Ab0LFU7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 15:59:35 -0500
In-Reply-To: <20101201110417.GA1653@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 1 Dec 2010 16:34:17 +0530

> If Lancer chip does not have posted RX buffers, it posts an RX completion entry
> with the same frag_index as the last valid completion. The Error bit is also
> set. In BE, a flush completion is indicated with a zero value for num_rcvd in
> the completion.
> Such completions don't carry any data and are not processed.
> This patch refactors code to handle both cases with the same code.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
