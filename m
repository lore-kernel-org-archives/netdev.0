From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 01/12] sky2: restore workarounds for lost interrupts
Date: Tue, 10 Jul 2007 12:24:53 -0400
Message-ID: <4693B2D5.9060103@pobox.com>
References: <20070709223332.966231494@linux-foundation.org> <20070709223453.040349359@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59930 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbXGJQY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:24:56 -0400
In-Reply-To: <20070709223453.040349359@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch restores a couple of workarounds from 2.6.16:
>  * restart transmit moderation timer in case it expires during IRQ routine
>  * default to having 10 HZ watchdog timer.
> At this point it more important not to hang than to worry about the
> power cost.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-12


