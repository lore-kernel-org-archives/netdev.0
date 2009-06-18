From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] sky2: fix shutdown synchronization
Date: Wed, 17 Jun 2009 18:50:50 -0700 (PDT)
Message-ID: <20090617.185050.31559732.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.828049268@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752752AbZFRBur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:50:47 -0400
In-Reply-To: <20090617173139.828049268@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:35 -0700

> The logic in sky2_down was incorrect. Receiver could report status
> after rx_stop was called.
> 
> The steps need to be:
>    * stop new frames from being transmitted
>    * shut off transmit/receive logic
>    * synchronize with NAPI to process status info about transmitter
>      and receiver
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
