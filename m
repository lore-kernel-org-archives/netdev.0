From: Steve.Glendinning@smsc.com
Subject: Re: SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Thu, 9 Oct 2008 13:51:24 +0100
Message-ID: <OF537E0E7B.B8F28FE1-ON802574DD.004653DF-802574DD.0046A74B@smsc.com>
References: <20081009182523.D6FF.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4826 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757529AbYJIMwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 08:52:25 -0400
In-Reply-To: <20081009182523.D6FF.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Masakazu, i see it now.  Patch to follow.

--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com





Masakazu Mokuno <mokuno@sm.sony.co.jp> 
09/10/2008 11:08

To
Steve Glendinning/SMSC@SMSC
cc
David Miller <davem@davemloft.net>, netdev@vger.kernel.org, Ian 
Saturley/SMSC@SMSC
Subject
Re: SMSC LAN9500 USB2.0 10/100 ethernet adapter driver






Hi

On Thu, 9 Oct 2008 09:48:16 +0100
Steve.Glendinning@smsc.com wrote:

> Hi David,
> 
> I don't see those warnings here on x86_64 (gcc 4.3.0, Fedora 9).  Which 
> arch/gcc version do you see them on?

I've got same results as davem:

  CC [M]  drivers/net/usb/smsc95xx.o
drivers/net/usb/smsc95xx.c: In function 'smsc95xx_write_reg_async':
drivers/net/usb/smsc95xx.c:348: warning: large integer implicitly 
truncated to unsigned type
drivers/net/usb/smsc95xx.c: In function 'smsc95xx_status':
drivers/net/usb/smsc95xx.c:548: warning: passing argument 1 of '__swab32s' 
makes pointer from integer without a cast

I'm using powerpc/x86 cross-compiler (ppu-gcc 4.1.1) included in Cell
SDK 3.0.  You can reach the gcc RPMs via:

                 http://www.bsc.es/projects/deepcomputing/linuxoncell/
                 (from 'Cell BE SDKs' item of the left menu of the page)

-- 
Masakazu Mokuno



