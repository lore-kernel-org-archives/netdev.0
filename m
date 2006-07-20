From: Dan Williams <dcbw@redhat.com>
Subject: Re: ipw2200: Driver lockup
Date: Wed, 19 Jul 2006 20:49:57 -0400
Message-ID: <1153356597.2542.7.camel@localhost.localdomain>
References: <20060719142833.GA21345@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49889 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964884AbWGTAs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 20:48:57 -0400
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060719142833.GA21345@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-19 at 10:28 -0400, Ralf Baechle wrote:
> I got the driver to die several times under the extreme condition at the
> KS / OLS with dozens to hundreds of other machines in the same room.  The
> last kernel message I got from about the time when wireless died was
> 
>   eth1: NETDEV_TX_BUSY returned; driver should report queue full via ieee_device->is_queue_full.

I actually get this quite a bit too, at least a couple times per day.
Sometimes the device goes down and you have to rmmod ipw2200, other
times it recovers.  But quite annoying anyway.

Anyone know exactly what that message means, and possibly how to fix it?

Dan

>   Ralf
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

