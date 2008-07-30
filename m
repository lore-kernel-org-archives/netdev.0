From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: send correct MTU value in PMTU (revised)
Date: Wed, 30 Jul 2008 16:28:18 -0700 (PDT)
Message-ID: <20080730.162818.208421272.davem@davemloft.net>
References: <20080730133259.576e0041@extreme>
	<20080730135008.4f98f5ee.akpm@linux-foundation.org>
	<20080730141017.0000aceb@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	simon.wunderlich@s2003.tu-chemnitz.de, siwu@hrz.tu-chemnitz.de
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752001AbYG3X2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:28:18 -0400
In-Reply-To: <20080730141017.0000aceb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 30 Jul 2008 14:10:17 -0700

> a) didn't want you holding onto old version, and it leaking upstream.
> b) didn't know how to spoof git's attribution
> c) fake_rtable gets initialized to zero already.
>    Since it is part of bridge structure and the whole bridge structure
>    is the private part of the bridge pseudo network device which
>    is initialized to zero as part of alloc_netdev.

I've applied Stephen's updated version of Simon's patch.

Thanks.
