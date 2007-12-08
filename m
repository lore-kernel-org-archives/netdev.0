From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 'default' vs. 'all'
Date: Sat, 08 Dec 2007 00:14:11 -0800 (PST)
Message-ID: <20071208.001411.86141788.yoshfuji@linux-ipv6.org>
References: <20071208.000429.66028544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43047 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154AbXLHINs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:13:48 -0500
In-Reply-To: <20071208.000429.66028544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20071208.000429.66028544.davem@davemloft.net> (at Sat, 08 Dec 2007 00:04:29 -0800 (PST)), David Miller <davem@davemloft.net> says:

> Herbert, Yoshifuji and I were just discussing the
> sysfs device attribute issue.
> 
> It's seems sane to me that if we had some kind of
> 'dirty' bit per attribute we could propagate default
> settings everywhere except where the dirty bit had
> been set.

One good event to propagate is the NETDEV_UP; if the dirty bit is
not set when the device is brought up, copy the default values to
the device.

Regards,

--yoshfuji @ Seattle
