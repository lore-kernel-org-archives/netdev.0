From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Mon, 10 Sep 2007 10:25:57 +0100
Message-ID: <46E50DA5.8050403@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <p737in19kxw.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38603 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668AbXIJJ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 05:26:00 -0400
In-Reply-To: <p737in19kxw.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> James Chapman <jchapman@katalix.com> writes:

> On some platforms the precise timers (like ktime_get()) can be slow,
> but often they are fast.  It might make sense to use a shorter
> constant time wait on those with fast timers at least. Right now this
> cannot be known by portable code, but there was a proposal some time
> ago to export some global estimate to tell how fast
> ktime_get().et.al. are. That could be reviewed.

Interesting. Is ktime_get() fast enough on P4 systems? I'll be using 
those to test with.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

