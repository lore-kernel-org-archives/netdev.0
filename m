From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 21:01:09 +0100
Message-ID: <20080120200109.GA31876@elte.hu>
References: <200801202053.30386.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47931 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755292AbYATUB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 15:01:26 -0500
Content-Disposition: inline
In-Reply-To: <200801202053.30386.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andi Kleen <ak@suse.de> wrote:

> My workstation running 2.6.24-rc8 just hung during shutdown with an 
> endless (or rather I didn't wait more than a few minutes) loop of
> 
> unregister_netdev: waiting for ppp-device to become free. Usage count 
> = 1
> 
> ppp-device was an active PPPoE device.
> 
> No more information currently.

i've seen such problems (locked up box with endless loop of usage count 
== 1) with pppoe in the past, and it seemed to be related to dynamic 
IPs. (i saw that well before 2.6.24 - reported it once to davem)

It seems to have stopped when i stopped using ipsec and started using 
vpnc. (but no firm info - this was sporadic - happened every few months 
or so) Are you using ipsec and dynamic IPs by any chance?

	Ingo
