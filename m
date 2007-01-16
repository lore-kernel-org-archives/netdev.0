From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Tue, 16 Jan 2007 13:28:52 +0100
Message-ID: <45ACC504.4060208@trash.net>
References: <20070116085611.GA1003@ff.dom.local> <45ACA6B6.1090902@trash.net> <20070116110244.GB1003@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49767 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbXAPM2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 07:28:54 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070116110244.GB1003@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Tue, Jan 16, 2007 at 11:19:34AM +0100, Patrick McHardy wrote:
> ...
> 
>>Right, this changes it from long (tc_core_usec2tick) to unsigned
>>int. It doesn't make any difference though, ... 
> 
> 
> ... if we count out reading_time_2tick, of course.

And this is a problem why? In the worst case (NET_SCH_CLK_CPU,
max rate 1/0.5us) it allows us to represent a transmission time
of 2^32/1000000/2s (where 2 is tick_in_usec), which is roughly
2147s.

If you still have doubts, please use numbers to demonstrate the
problem.


