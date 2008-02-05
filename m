From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 5/7] bluetooth: blacklist another Broadcom BCM2035
	device
Date: Tue, 05 Feb 2008 17:51:44 +0100
Message-ID: <1202230304.15090.107.camel@violet>
References: <200802050747.m157lwwg010458@imap1.linux-foundation.org>
	 <20080205.031025.171453745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	andy@smile.org.ua
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33852 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbYBEQvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:51:15 -0500
In-Reply-To: <20080205.031025.171453745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> > From: Andy Shevchenko <andy@smile.org.ua>
> > 
> > This device is recognized as bluetooth, but still not works.
> > 
> > Signed-off-by: Andy Shevchenko <andy@smile.org.ua>
> > Cc: Marcel Holtmann <marcel@holtmann.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Applied.
> 
> But, what driver should drive this device?

the hci_usb will driver this device, but since it is Broadcom based it
needs some extra quirks to work accordingly.

Regards

Marcel


