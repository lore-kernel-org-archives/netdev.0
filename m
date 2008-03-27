From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 13:32:48 +0100
Message-ID: <20080327123248.GD2845@ami.dom.local>
References: <20080327085542.GA2778@ami.dom.local> <20080327021812.601776b8.akpm@linux-foundation.org> <1206615379.8514.502.camel@twins> <20080327.040334.25440988.davem@davemloft.net> <47EB8C06.4030306@better.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, mingo@elte.hu
To: Marcus Better <marcus@better.se>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760960AbYC0M11@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47EB8C06.4030306@better.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2008 at 12:59:02PM +0100, Marcus Better wrote:
> David Miller wrote:
>> Can some test if using local_irq_{save,restore}() in
>> napi_complete() cures this lockdep warning?

Isn't it now justified enough without lockdep's ack?

> I cannot reproduce the bug, so cannot help much.

Marcus, you've helped here very much and enough!

Thanks,
Jarek P.
