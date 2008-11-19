From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 11:21:46 +0100
Message-ID: <20081119102145.GA15741@elte.hu>
References: <20081119093004.GD22309@elte.hu> <20081119.014222.193698982.davem@davemloft.net> <20081119101441.GB6184@elte.hu> <20081119.021701.133290720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, jeff@garzik.org, johannes@sipsolutions.net,
	wferi@niif.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:34192 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbYKSKWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 05:22:00 -0500
Content-Disposition: inline
In-Reply-To: <20081119.021701.133290720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 19 Nov 2008 11:14:41 +0100
> 
> > Thanks! We strengthened/cleaned up the bh checks a tiny bit 
> > recently, maybe that caused this to pop up. It might explain some 
> > netconsole lockups perhaps? Or, the new warning might be bogus. 
> > It's a bit of a maze.
> 
> See my other reply to Jarek's patch posting, we're supposed to 
> ignore all RX packets in this situation, and all the logic appears 
> to be there, but it's not happening on that person's system for some 
> reason.

Saw that ... an insanely complex scenario.

So at least there's a partial result: it appears to not be a false 
positive warning in the generic softirq/lockdep code.

	Ingo
