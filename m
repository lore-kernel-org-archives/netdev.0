From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 02:22:51 -0800 (PST)
Message-ID: <20081119.022251.248772210.davem@davemloft.net>
References: <20081119101441.GB6184@elte.hu>
	<20081119.021701.133290720.davem@davemloft.net>
	<20081119102145.GA15741@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jeff@garzik.org, johannes@sipsolutions.net,
	wferi@niif.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751939AbYKSKWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 05:22:51 -0500
In-Reply-To: <20081119102145.GA15741@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 19 Nov 2008 11:21:46 +0100

> So at least there's a partial result: it appears to not be a false 
> positive warning in the generic softirq/lockdep code.

Right, it's totally legit.
