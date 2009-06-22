From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: stop unnecessary polling when using msi-x
Date: Mon, 22 Jun 2009 01:52:47 -0700 (PDT)
Message-ID: <20090622.015247.131948575.davem@davemloft.net>
References: <4A3ABA6C.9030604@intel.com>
	<20090619.002454.04323414.davem@davemloft.net>
	<20090619150634.GH8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, stable@kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755482AbZFVIwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 04:52:44 -0400
In-Reply-To: <20090619150634.GH8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 19 Jun 2009 11:06:34 -0400

> I did some more testing with 2.6.30 and ksoftirqd uses 100% of the cpu
> once the device is up.  With this patch it does not, so it should
> probably go into 2.6.29-stable as well.

Ok, will queue it up.
