From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 02:03:42 -0800 (PST)
Message-ID: <20070221.020342.59655958.davem@davemloft.net>
References: <20070221085608.GC1903@2ka.mipt.ru>
	<20070221.013440.39157749.davem@davemloft.net>
	<20070221095109.GA308@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: medwards.linux@gmail.com, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161179AbXBUKDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 05:03:44 -0500
In-Reply-To: <20070221095109.GA308@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 21 Feb 2007 12:51:09 +0300

> Linux route cache does not change $c (third parameter), and it _seems_
> that distribution for the random $a and $b is fair, while when $c is
> formed over attacker's data, random per-boot $initval does not help.

It is not only initialized per-boot, it is also regenerated
every 10 minutes by default, via rt_secret_rebuild().
