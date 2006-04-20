From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix locking in gianfar
Date: Thu, 20 Apr 2006 17:40:10 -0400
Message-ID: <4447FFBA.50002@garzik.org>
References: <9312C75A-DB98-4818-859E-906FA6461489@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:9629 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751343AbWDTVkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 17:40:13 -0400
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <9312C75A-DB98-4818-859E-906FA6461489@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> This patch fixes several bugs in the gianfar driver, including a major one
> where spinlocks were horribly broken:
> 
> * Split gianfar locks into two types: TX and RX
> * Made it so gfar_start() now clears RHALT
> * Fixed a bug where calling gfar_start_xmit() with interrupts off would
> corrupt the interrupt state
> * Fixed a bug where a frame could potentially arrive, and never be handled
> (if no more frames arrived
> * Fixed a bug where the rx_work_limit would never be observed by the rx
> completion code
> * Fixed a bug where the interrupt handlers were not actually protected by
> their spinlocks
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

ACK but failed:


[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
1 patch(es) to process.

Applying 'Fix locking in gianfar'

fatal: corrupt patch at line 19

