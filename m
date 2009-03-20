From: David Miller <davem@davemloft.net>
Subject: Re: e1000 under VMware doesn't work since 2.6.27.16 - BISECTED
Date: Fri, 20 Mar 2009 16:55:16 -0700 (PDT)
Message-ID: <20090320.165516.112348262.davem@davemloft.net>
References: <49C3C726.4000405@bcsoft.de>
	<20090320.155739.93629479.davem@davemloft.net>
	<adafxh7yext.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drifter@bcsoft.de, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33058
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751840AbZCTXz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:55:29 -0400
In-Reply-To: <adafxh7yext.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 20 Mar 2009 16:03:58 -0700

>  > > we're using virtual machines under VMware with the e1000 emulated
>  > > network card.
> 
>  > Sounds like vmware doesn't emulate the e1000 accurately enough.
> 
> I would consider problems with the vmware emulated e1000 to be similar
> to hardware quirks in some other chip rev supported by the e1000
> driver.  If a driver change broke e1000 inside a vmware VM then we
> should probably fix the kernel if possible (although vmware probably
> wants to improve their emulation too).

If such a "fix" would be to the detriment of real actual hardware,
this logic doesn't hold.

The same applies to cases like qemu as well.
