From: Elina Pasheva <epasheva@sierrawireless.com>
Subject: RE: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c
	driver
Date: Tue, 4 May 2010 13:18:22 -0700
Message-ID: <1273004302.6718.10.camel@Linuxdev4-laptop>
References: <1272497304.8835.2.camel@Linuxdev4-laptop>
	 ,<20100501.180829.139101312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: <epasheva@sierrawireless.com>,
	Rory Filer <rfiler@SierraWireless.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"dbrownell@users.sourceforge.net" <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from carmd-sa02.sierrawireless.com ([208.81.121.46]:59369 "EHLO
	carmd-sa02.sierrawireless.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754301Ab0EDUSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 16:18:30 -0400
In-Reply-To: <20100501.180829.139101312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Saturday, May 01, 2010 6:08 PM David Miller wrote:

>>>From: Elina Pasheva <epasheva@sierrawireless.com>
>>>Date: Wed, 28 Apr 2010 16:28:24 -0700

>>> Subject: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c driver
>>> From: Elina Pasheva <epasheva@sierrawireless.com>
>>>
>>> The following patch adds the initiation of the sync sequence to
>>> "sierra_net_bind()". If this step is omitted, the modem will never sync up
>>> with the host and it will not be possible to establish a data connection.
>>> This is a high priority patch.
>>>
>>> This patch has been checked against net-2.6 tree.
>>> Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
>>> Signed-off-by: Rory Filer <rfiler@sierrawireless.com>
>>> Tested-by: Elina Pasheva <epasheva@sierrawireless.com>

>>Applied.

>Thank you very much, David!
>Elina

Hi David,
What are the chances of this patch to be in the kernel-2.6.34 release?
Without this patch the driver sierra_net (currently in kernel-2.6.34-rc6) 
will not work.

Thank you,
Elina




