From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 7/8] hci_usb: replace mb with smp_mb
Date: Tue, 23 Sep 2008 06:54:18 +0200
Message-ID: <1222145658.13064.18.camel@californication>
References: <200809222150.m8MLog27031875@imap1.linux-foundation.org>
	 <20080922.192207.178559086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	tom.leiming@gmail.com, hidave.darkstar@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49234 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbYIWExV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:53:21 -0400
In-Reply-To: <20080922.192207.178559086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > smp_mb is enough for ordering memory operations among processors,and mb is
> > more expensive than smp_mb for UP machine, so replace it with smp_mb().
> > 
> > Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> > Acked-by: Marcel Holtmann <marcel@holtmann.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Since this already ACK'd by Marcel, I've added this to net-next-2.6

that is absolutely fine by me. The hci_usb driver is a dead end and we
do have multiple people now looking at and testing btusb. So expect the
hci_usb driver to go away soon. Either 2.6.28 or 2.6.29.

Regards

Marcel


