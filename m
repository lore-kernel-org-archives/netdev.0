From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Tue, 27 May 2008 14:32:12 -0700
Message-ID: <200805271432.12881.david-b@pacbell.net>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080525181329.GA5044@yamamaya.is-a-geek.org> <20080527062153.GA3651@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-acpi@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.sp1.yahoo.com ([69.147.64.96]:47788 "HELO
	smtp123.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758500AbYE0VcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 17:32:15 -0400
In-Reply-To: <20080527062153.GA3651@yamamaya.is-a-geek.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 May 2008, Tobias Diedrich wrote:
> The platform_enable_wakeup() hook is still there, but unused.

The patches to support it (still) haven't been merged.


> AFAICS this patch should solve the "'ethtool -s eth0 wol g' doesn't
> suffice, I also have to write magic values into /proc/acpi/wakeup"
> issue.

Yeah; under ACPI, PCI does not act like it does everywhere else.
Nor does wakeup in general.

After sending patches to fix that for a couple years now, I'm
well past being tired of doing that.  I suggest it's overdue for
the ACPI team to get this part of their act together.

That is:  either start merging those patches, possibly with updates
to handle broken hardware better; or rewrite them; ... or just say
explicitly the message I've been receiving:  "Linux ACPI will never
support wakeup the way the rest of Linux can and does".  (And the
"why" should be something reasonable.)

