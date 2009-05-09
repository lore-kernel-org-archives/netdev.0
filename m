From: David Miller <davem@davemloft.net>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Sat, 09 May 2009 13:27:33 -0700 (PDT)
Message-ID: <20090509.132733.213857911.davem@davemloft.net>
References: <1241433136.6126.70.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052AbZEIU1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:27:37 -0400
In-Reply-To: <1241433136.6126.70.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 04 May 2009 11:32:16 +0100

> I don't have to explicitly remove the files, do I? They go away
> naturally when the device is unregistered?

I'm not so sure about this.  I can't see anything in the
drivers/base/core.c code that automatically deletes anything
other than device groups and attributes.
