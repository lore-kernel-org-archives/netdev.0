From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: Re: SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Thu, 09 Oct 2008 19:08:37 +0900
Message-ID: <20081009182523.D6FF.40F06B3A@sm.sony.co.jp>
References: <20081008.164520.27995219.davem@davemloft.net> <OF78A38490.DBE764E4-ON802574DD.002FF53B-802574DD.003064CC@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms5.Sony.CO.JP ([211.125.136.201]:63491 "EHLO ms5.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbYJIKIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 06:08:53 -0400
In-Reply-To: <OF78A38490.DBE764E4-ON802574DD.002FF53B-802574DD.003064CC@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
drivers/net/usb/smsc95xx.c:348: warning: large integer implicitly truncated to unsigned type
drivers/net/usb/smsc95xx.c: In function 'smsc95xx_status':
drivers/net/usb/smsc95xx.c:548: warning: passing argument 1 of '__swab32s' makes pointer from integer without a cast

I'm using powerpc/x86 cross-compiler (ppu-gcc 4.1.1) included in Cell
SDK 3.0.  You can reach the gcc RPMs via:

	http://www.bsc.es/projects/deepcomputing/linuxoncell/
	(from 'Cell BE SDKs' item of the left menu of the page)

-- 
Masakazu Mokuno

