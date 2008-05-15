From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 15:21:49 -0400
Message-ID: <482C8D4D.3040702@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38624 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbYEOTV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 15:21:57 -0400
In-Reply-To: <482C8550.5000909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> How about the non-NAPI and non-throttled case? I would argue that without any irq
> mitigation we can still use SA_RANDOM. Many (e.g. embedded) devices will want some

When was the last time we added a new driver for new hardware, and it 
didn't support NAPI and/or hw mitigation?  They are few and far between, 
and getting ever more rare.


> extra form of entropy, and providing them it in this form will be very beneficial
> as these devices more commonly have no other form of entropy anymore.

"no other form of entropy"?   See examples in this thread.

	Jeff


