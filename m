From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re:[patch] genirq: temporary fix for level-triggered IRQ resend
Date: Thu,  9 Aug 2007 10:12:27 +0200
Message-ID: <JMHYSR$115A35C556FF1DC799C39F5A854755BC@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "mingo" <mingo@elte.hu>,
	"torvalds" <torvalds@linux-foundation.org>,
	"tglx" <tglx@linutronix.de>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xandmail.com ([212.155.184.97]:44423 "EHLO
	mail.xandmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763164AbXHIINR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 04:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi,
> 
> I see there is a bit of complaining on this original resend temporary
> patch. But, since it seems to do a good job for some people, here is
> my proposal to limit the 'range of fire' a little bit.
> 
> Marcin and Jean-Baptiste: try to test this with 2.6.23-rc2, please.
> (Unless Ingo or Thomas have other plans with this problem?)

2.6.23-rc2 + this patch, and the box's cards are still networking after 20 hours.

RX bytes:452423991847 (421.3 GiB)  TX bytes:13464471620 (12.5 GiB)

still testing.

Jb


