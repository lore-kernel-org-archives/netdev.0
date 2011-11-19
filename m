From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] e1000: possible deadlock scenario caught by lockdep
Date: Fri, 18 Nov 2011 20:47:16 -0500
Message-ID: <1321667236.3533.59.camel@frodo>
References: <1321579620.3533.29.camel@frodo>
	 <20111118085737.0000387f@unknown>  <20111118151704.0000007b@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:58104 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1KSBrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 20:47:20 -0500
In-Reply-To: <20111118151704.0000007b@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-18 at 15:17 -0800, Jesse Brandeburg wrote:

> this is a proposed patch to fix the issue:
> if it works for you please let me know and I will submit it officially
> through our process

Well, the one time I tested it, it didn't crash and it didn't give a
lockdep splat either. I'll add it and reboot it a few more times and
I'll holler if something bad happens.

Tested-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
