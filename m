From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] tg3: restore rx_dropped accounting
Date: Mon, 11 Oct 2010 16:06:41 -0700 (PDT)
Message-ID: <20101011.160641.71122025.davem@davemloft.net>
References: <1286776552.2692.232.camel@edumazet-laptop>
	<20101011222657.GA7307@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328Ab0JKXGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 19:06:19 -0400
In-Reply-To: <20101011222657.GA7307@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 11 Oct 2010 15:26:57 -0700

> On Sun, Oct 10, 2010 at 10:55:52PM -0700, Eric Dumazet wrote:
>> commit 511d22247be7 (tg3: 64 bit stats on all arches), overlooked the
>> rx_dropped accounting.
>> 
>> We use a full "struct rtnl_link_stats64" to hold rx_dropped value, but
>> forgot to report it in tg3_get_stats64().
>> 
>> Use an "unsigned long" instead to shrink "struct tg3" by 176 bytes, and
>> report this value to stats readers.
>> 
>> Increment rx_dropped counter for oversized frames.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

Applied, thanks Matt.
