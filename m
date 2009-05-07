From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: fix calculation of res_size for ioremap
Date: Thu, 7 May 2009 10:45:05 +0100
Message-ID: <OF9818CA9E.B06011AE-ON802575AF.00354281-802575AF.00358C0A@smsc.com>
References: <1241613956-7940-1-git-send-email-mludwig@ultratronik.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Matthias Ludwig <mludwig@ultratronik.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3892 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752961AbZEGJpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 05:45:21 -0400
In-Reply-To: <1241613956-7940-1-git-send-email-mludwig@ultratronik.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthias Ludwig <mludwig@ultratronik.de> wrote on 06/05/2009 13:45:56:

> fix size of remaped iomem, which is 1 byte to small
> (e.g. mappes only 0xff bytes instead of 0x100)

*shrug* - I guess we should fix this for correctness but the highest
register offset in the device is 0xb4 so this shouldn't cause any
actual problems.

> Signed-off-by: Matthias Ludwig <mludwig@ultratronik.de>

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

