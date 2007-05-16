From: David Miller <davem@davemloft.net>
Subject: Re: incorrect defines in mii.h
Date: Wed, 16 May 2007 00:23:28 -0700 (PDT)
Message-ID: <20070516.002328.122616772.davem@davemloft.net>
References: <8496f91a0705160001t1cb1f3aj30642db713bccbe3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755538AbXEPHXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 03:23:22 -0400
In-Reply-To: <8496f91a0705160001t1cb1f3aj30642db713bccbe3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Date: Wed, 16 May 2007 11:01:04 +0400

> Hi all!
> 
> The following defines are incorrect (include/linux/mii.h):
> 
> #define BMSR_100FULL2           0x0200  /* Can do 100BASE-T2 HDX */
> #define BMSR_100HALF2           0x0400  /* Can do 100BASE-T2 FDX */
> 
> it must be
> 
> #define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX */
> #define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX */

Thanks I will fix these.

It is a good thing they are currently unused :-)
