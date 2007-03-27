From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 15:30:25 -0700 (PDT)
Message-ID: <20070327.153025.45876618.davem@davemloft.net>
References: <20070327214754.GA11677@dag-work>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.ne, netdev@vger.kernel.org
To: dagriego@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934235AbXC0Wa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 18:30:27 -0400
In-Reply-To: <20070327214754.GA11677@dag-work>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dagriego@gmail.com (David Griego)
Date: Tue, 27 Mar 2007 14:47:54 -0700

> Adds an IOCTL for aborting established TCP connections, and is
> designed to be an HA performance improvement for cleaning up, failure 
> notification, and application termination.
> 
> Signed-off-by:  David Griego <dagriego@gmail.com>

SO_LINGER with a zero linger time plus close() isn't working
properly?

There is no reason for this ioctl at all.  Either existing
facilities provide what you need or what you want is a
protocol violation we can't do.

