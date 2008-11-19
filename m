From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 02:17:01 -0800 (PST)
Message-ID: <20081119.021701.133290720.davem@davemloft.net>
References: <20081119093004.GD22309@elte.hu>
	<20081119.014222.193698982.davem@davemloft.net>
	<20081119101441.GB6184@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jeff@garzik.org, johannes@sipsolutions.net,
	wferi@niif.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752816AbYKSKRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 05:17:02 -0500
In-Reply-To: <20081119101441.GB6184@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 19 Nov 2008 11:14:41 +0100

> Thanks! We strengthened/cleaned up the bh checks a tiny bit recently, 
> maybe that caused this to pop up. It might explain some netconsole 
> lockups perhaps? Or, the new warning might be bogus. It's a bit of a 
> maze.

See my other reply to Jarek's patch posting, we're supposed to
ignore all RX packets in this situation, and all the logic appears
to be there, but it's not happening on that person's system for some
reason.
