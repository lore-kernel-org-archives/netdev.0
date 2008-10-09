From: Steve.Glendinning@smsc.com
Subject: Re: SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Thu, 9 Oct 2008 09:48:16 +0100
Message-ID: <OF78A38490.DBE764E4-ON802574DD.002FF53B-802574DD.003064CC@smsc.com>
References: <20081008.164520.27995219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1919 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753392AbYJIIs6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 04:48:58 -0400
In-Reply-To: <20081008.164520.27995219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I don't see those warnings here on x86_64 (gcc 4.3.0, Fedora 9).  Which 
arch/gcc version do you see them on?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com





David Miller <davem@davemloft.net> 
09/10/2008 00:45

To
Steve Glendinning/SMSC@SMSC
cc
netdev@vger.kernel.org
Subject
Re: SMSC LAN9500 USB2.0 10/100 ethernet adapter driver







I've added this patch to net-next-2.6, thanks.

But please fix the following warnings that are generated
on 64-bit builds:

drivers/net/usb/smsc95xx.c: In function ?smsc95xx_write_reg_async?:
drivers/net/usb/smsc95xx.c:348: warning: large integer implicitly 
truncated to unsigned type
drivers/net/usb/smsc95xx.c: In function ?smsc95xx_status?:
drivers/net/usb/smsc95xx.c:548: warning: passing argument 1 of ?__swab32s? 
makes pointer from integer without a cast


