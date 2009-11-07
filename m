From: David Miller <davem@davemloft.net>
Subject: Re: hisax: remove bad udelay call to fix build error on ARM
Date: Fri, 06 Nov 2009 20:34:21 -0800 (PST)
Message-ID: <20091106.203421.114610537.davem@davemloft.net>
References: <20091107005234.GA1678@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, tilman@imap.cc, netdev@vger.kernel.org
To: tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46688
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760205AbZKGEdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:33:55 -0500
In-Reply-To: <20091107005234.GA1678@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Michlmayr <tbm@cyrius.com>
Date: Sat, 7 Nov 2009 00:52:34 +0000

> The hisax ISDN driver fails to build on ARM with CONFIG_HISAX_ELSA:
> 
> | drivers/built-in.o: In function `modem_set_dial':
> | drivers/isdn/hisax/elsa_ser.c:535: undefined reference to `__bad_udelay'
> | drivers/isdn/hisax/elsa_ser.c:544: undefined reference to `__bad_udelay'
> | drivers/built-in.o: In function `modem_set_init':
> | drivers/isdn/hisax/elsa_ser.c:486: undefined reference to `__bad_udelay'
> | [...]
> 
> According to the comment in arch/arm/include/asm/delay.h, __bad_udelay
> is specifically designed on ARM to produce a build failure when udelay
> is called with a value > 2000.
> 
> Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

Applied to net-2.6
