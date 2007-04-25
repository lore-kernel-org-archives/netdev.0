From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]:Replace with time_before in net/ipv4/ipip.c
Date: Wed, 25 Apr 2007 01:19:38 -0700 (PDT)
Message-ID: <20070425.011938.74750660.davem@davemloft.net>
References: <1177480813.27118.17.camel@shani-win>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: shani.moideen@wipro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423282AbXDYITb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 04:19:31 -0400
In-Reply-To: <1177480813.27118.17.camel@shani-win>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shani Moideen <shani.moideen@wipro.com>
Date: Wed, 25 Apr 2007 11:30:13 +0530

> Replacing (jiffies - errtime < TIMEOUT) with time_before in net/ipv4/ipip.c
> 
> thanks.
> 
> Signed-off-by: Shani Moideen <shani.moideen@wipro.com>

The test you are replacing actually gives a larger window
of acceptance than time_before() does.

It's been a long standing issue whether we should give up
this semantic advantage for the sake of code cleanliness
in the networking code.

