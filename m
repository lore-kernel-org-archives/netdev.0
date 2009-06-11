From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] qlge: Allow RX buf rings to be > than
 4096 bytes.
Date: Thu, 11 Jun 2009 02:37:19 -0700 (PDT)
Message-ID: <20090611.023719.251163841.davem@davemloft.net>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
	<1244684975-10211-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760842AbZFKJhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:37:17 -0400
In-Reply-To: <1244684975-10211-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 10 Jun 2009 18:49:34 -0700

> RX buffer rings can be comprised of non-contiguous fixed
> size chunks of memory. The ring is given to the hardware
> as a pointer to a location that stores the location of
> the queue.  If the queue is greater than 4096 bytes then
> the hardware gets a list of said pointers.
> This patch addes the necessary logic to generate the list if
> the queue size exceeds 4096.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
