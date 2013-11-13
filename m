From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fw: [Bug 63321] tcp_fastretrans_alert
Date: Wed, 13 Nov 2013 01:45:51 +0000
Message-ID: <1384307151.3802.73.camel@bwh-desktop.uk.level5networks.com>
References: <20131112172615.498b3ac9@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48915 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3KMBpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:45:53 -0500
In-Reply-To: <20131112172615.498b3ac9@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 17:26 -0800, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Tue, 12 Nov 2013 08:43:45 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 63321] tcp_fastretrans_alert
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=63321
> 
> --- Comment #3 from root@securitydot.net ---
> Once again someone is delaying a fix for a major issue causing a lot of
> trouble. Please fix it...
> 
> WARNING: CPU: 2 PID: 0 at net/ipv4/tcp_input.c:2711
> tcp_fastretrans_alert+0x56c/0x580()
[...]
> CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W    3.11.6-1.el6.elrepo.x86_64

I think this is fixed by:

commit 031afe4990a7c9dbff41a3a742c44d3e740ea0a1
Author: Yuchung Cheng <ycheng@google.com>
Date:   Sat Oct 12 10:16:27 2013 -0700

    tcp: fix incorrect ca_state in tail loss probe

which went into 3.12-rc7 and then 3.11.7.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
