From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] can: at91_can: clean up usage of
 AT91_MB_RX_FIRST and AT91_MB_RX_NUM
Date: Fri, 21 Jan 2011 16:54:09 -0800 (PST)
Message-ID: <20110121.165409.200115988.davem@davemloft.net>
References: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>
	<1294752085-30151-2-git-send-email-mkl@pengutronix.de>
	<4D349D8C.3010403@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	wg@grandegger.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791Ab1AVAxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 19:53:35 -0500
In-Reply-To: <4D349D8C.3010403@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 17 Jan 2011 20:50:36 +0100

> On 01/11/2011 02:21 PM, Marc Kleine-Budde wrote:
>> This patch cleans up the usage of two macros which specify the mailbox
>> usage. AT91_MB_RX_FIRST and AT91_MB_RX_NUM define the first and the
>> number of RX mailboxes. The current driver uses these variables in an
>> unclean way; assuming that AT91_MB_RX_FIRST is 0;
>> 
>> This patch cleans up the usage of these macros, no longer assuming
>> AT91_MB_RX_FIRST == 0.
>> 
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Any comments on this?

I would also seriously like to see these changes get some feedback,
they've been rotting in patchwork for more than a week.
