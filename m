From: David Miller <davem@davemloft.net>
Subject: Re: IGB handling of zero length checksumming?
Date: Sun, 11 Apr 2010 14:42:35 -0700 (PDT)
Message-ID: <20100411.144235.226765248.davem@davemloft.net>
References: <20100411.024027.120459168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42359
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702Ab0DKVmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 17:42:31 -0400
In-Reply-To: <20100411.024027.120459168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 11 Apr 2010 02:40:27 -0700 (PDT)

> 
> If the IGB is given a "skb->ip_summed === CHECKSUM_PARTIAL" packet and
> the data area past the TCP header is of zero length, will it do the
> right thing?

Hey guys you don't have to worry about this.

The problem turned out to be somewhere else. :-)

