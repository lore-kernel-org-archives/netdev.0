From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: push blocking slaves to forwarding when turning
 stp off
Date: Tue, 20 Dec 2011 10:11:17 -0800
Message-ID: <20111220101117.2a3eb12f@nehalam.linuxnetplumber.net>
References: <201112131136.25919.vitas@nppfactor.kiev.ua>
	<20111213161613.0c59ab36@nehalam.linuxnetplumber.net>
	<201112141132.51867.vitas@nppfactor.kiev.ua>
	<201112201259.12086.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Michael Tremer <michael.tremer@ipfire.org>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51713 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab1LTSLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 13:11:20 -0500
In-Reply-To: <201112201259.12086.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Dec 2011 12:59:11 +0200
Vitalii Demianets <vitas@nppfactor.kiev.ua> wrote:

> Hello, Stephen!
> I can not understand your silence.
> There are issues fixed by the patch in question. For example, if the interface 
> is left in blocking state after stp was turned off, that state is not 
> stable - it can flip to forwarding state in unpredictable times, e.g. when 
> _any other_ slave of the bridge goes up or down. Do you think user wants 
> exactly that unpredictable state change?
> Also, the code in question in function br_stp_stop(), namely 
> br_port_state_selection(br) call, does exactly nothing except wasting cpu 
> cycles. Isn't it worth fixing?
> 

I had to go do real work last week.
Let me test and look at it more detail.
There is no urgency, the problem has existed for many years.
