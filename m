From: David Miller <davem@davemloft.net>
Subject: Re: __bad_udelay in network driver breaks build
Date: Mon, 25 Oct 2010 16:48:20 -0700 (PDT)
Message-ID: <20101025.164820.112608218.davem@davemloft.net>
References: <20101018115230.GA27565@basil.fritz.box>
	<20101025.130513.102558756.davem@davemloft.net>
	<20101025221042.GE17622@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758333Ab0JYXr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 19:47:57 -0400
In-Reply-To: <20101025221042.GE17622@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 26 Oct 2010 00:10:42 +0200

> In file included from /home/lsrc/git/linux-2.6/drivers/net/igbvf/ethtool.c:36:0:
> /home/lsrc/git/linux-2.6/drivers/net/igbvf/igbvf.h:129:15: error: duplicate member 'page'
> make[5]: *** [drivers/net/igbvf/ethtool.o] Error 1
> make[4]: *** [drivers/net/igbvf] Error 2

Oh that's fun :-)

Intel folks please take a look.
