From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO
 selection based on L4 ports
Date: Wed, 20 Feb 2008 23:16:37 +0100
Message-ID: <47BCA6C5.1070805@trash.net>
References: <Pine.GSO.4.10.10802201644130.11320-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61622 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbYBTWQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:16:49 -0500
In-Reply-To: <Pine.GSO.4.10.10802201644130.11320-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Resubmit #2
> - Transmit fifo selection based on TCP/UDP ports.
> - Added tx_steering_type loadable parameter for transmit fifo selection.
>   0x0 NO_STEERING: Default FIFO is selected.
>   0x1 TX_PRIORITY_STEERING: FIFO is selected based on skb->priority.
>   0x2 TX_DEFAULT_STEERING: FIFO is selected based on L4 Ports.
>   

Why duplicate the generic multiqueue classification?


