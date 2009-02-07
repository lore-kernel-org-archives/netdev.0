From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_dma: call dmaengine_get only if NET_DMA enabled
Date: Fri, 06 Feb 2009 19:29:10 -0800 (PST)
Message-ID: <20090206.192910.42610645.davem@davemloft.net>
References: <e9c3a7c20902061315n7184c55ck7fcaa2c519a035d4@mail.gmail.com>
	<20090206.140912.40800913.davem@davemloft.net>
	<e9c3a7c20902061452r40a97fa2p1fccfa78e3905458@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anemo@mba.ocn.ne.jp, maciej.sosnowski@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbZBGD3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 22:29:14 -0500
In-Reply-To: <e9c3a7c20902061452r40a97fa2p1fccfa78e3905458@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Feb 2009 15:52:35 -0700

> Yes, it has been on the todo list for a while, but I eventually want
> the net case to look more like the raid case.  I.e. have one code path
> that picks async versus sync at runtime, with the option to compile
> out async support with header file ifdefs only.

And how does any of that get us any closer to a fix right now
for this problem that doesn't require an ifdef?

Someone please work on this.
