From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Mon, 18 Apr 2011 22:54:00 -0700 (PDT)
Message-ID: <20110418.225400.189709717.davem@davemloft.net>
References: <20110413174758.GA17579@electric-eye.fr.zoreil.com>
	<1302718764.3167.7.camel@lap75545.ornl.gov>
	<20110418180857.GB18469@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org, nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751556Ab1DSFyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:54:35 -0400
In-Reply-To: <20110418180857.GB18469@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 18 Apr 2011 20:08:57 +0200

> [...]
>> I've attached my ancient patch, if it helps.
> 
> Thanks, it works way better now (see below). It is ok for me to use
> you s-o-b on it ?
> 
> I have given it a try on 8169, 8168b, 8168d, 8102e and the load can
> dramatically fall (more at 1000 Mbps than at 100 Mbps).
> 
> David (M.), should it go through net-next or be made ready for net-2.6 ?
> 
> Subject: [PATCH] r8169: TSO fixes.

Francois, since TSO is disabled by default I'm applying this to
net-next-2.6, thanks!

Maybe we can progressively start to try and turn these things on
by default now that we know more about the TX descriptor layout
differences.
