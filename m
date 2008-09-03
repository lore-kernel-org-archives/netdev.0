From: David Miller <davem@davemloft.net>
Subject: Re: SunHME: trying to enable netconsole/netpolling
Date: Wed, 03 Sep 2008 13:59:04 -0700 (PDT)
Message-ID: <20080903.135904.18076182.davem@davemloft.net>
References: <a4423d670809030926v369ed065w437d35caa6b016a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752705AbYICU7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 16:59:11 -0400
In-Reply-To: <a4423d670809030926v369ed065w437d35caa6b016a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Wed, 3 Sep 2008 20:26:54 +0400

> Hi David
> 
> Can you please advice
> I am a newbie here.
> I am trying to enable netconsole output with sunhme card,
> I found that poll_controller is not defined and defined it
> as it is defined in other drivers (just to watch if it will work, I
> dont understand this code yet)
> My patch is in attach.
> My card is connected to PCI bus.

It isn't going to work until sunhme is converted to NAPI, and that
may never happen.

So unless someone knowledgable wants to do the work, which certianly
is not me, sunhme for now will not support netconsole.
