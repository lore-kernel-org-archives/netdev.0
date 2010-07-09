From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6 net-next-2.6] vxge: Remove queue_state references
Date: Thu, 08 Jul 2010 23:47:33 -0700 (PDT)
Message-ID: <20100708.234733.241916115.davem@davemloft.net>
References: <20100708191957.GA15167@exar.com>
	<20100708231936.GA19237@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sreenivasa.Honnur@exar.com,
	ramkrishna.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab0GIGr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:47:28 -0400
In-Reply-To: <20100708231936.GA19237@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 8 Jul 2010 18:19:37 -0500

> On Thu, Jul 08, 2010 at 12:19:57PM -0700, Jon Mason wrote:
>> Remove queue_state references, as they are no longer necessary.
>> 
>> Also, The driver needs to start/stop the queue regardless of which type
>> of steering is enabled.  Remove checks for TX_MULTIQ_STEERING only and
>> start/stop for all steering types.
>> 
>> Signed-off-by: Jon Mason <jon.mason@exar.com>
>> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
>> Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
> 
> Ram's e-mail address is incorrect in this series.  Would you like me
> to resubmit with it corrected?

The series ended up needing to be respun anyways since the
txq->trans_start change is invalid.
