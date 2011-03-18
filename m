From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Thu, 17 Mar 2011 21:51:50 -0700 (PDT)
Message-ID: <20110317.215150.112598866.davem@davemloft.net>
References: <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753202Ab1CREvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 00:51:13 -0400
In-Reply-To: <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Thu, 17 Mar 2011 21:33:50 -0700

> Yes I'm familiar with ss and how inet_csk_diag_fill() calls into
> tcp_diag_get_info(),..., etc. Like I mentioned previously the netlink
> interface
> requires a new version of reader app (e.g., ss) to ship every time a new
> counter is added and exported by the kernel, whereas /proc/net/tcp does
> not have such a problem.

You can add new netlink attributes to portably extend the existing
info, and also to add a mechanism by which to make 'ss' utility
upgrades unnecessary.

Please, just use modern mechanisms like netlink and leave legacy
bits like /proc/net/tcp alone, thank you.
