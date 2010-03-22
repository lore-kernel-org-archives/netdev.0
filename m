From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Patch v2] netpoll: warn when there are spaces in parameters
Date: Mon, 22 Mar 2010 17:22:15 -0500
Message-ID: <1269296535.3552.10.camel@calx>
References: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	elendil@planet.nl, David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:54131 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617Ab0CVWWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 18:22:21 -0400
In-Reply-To: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-22 at 04:59 -0400, Amerigo Wang wrote:
> +			printk(KERN_INFO "%s: warning: whitespace"
> +					"is not allowed\n", np->name);

Is it a warning or is it info? If it's a warning, then we probably need
to add "netpoll" or whatever to the message so that people who've got a
warning-level threshold will know what it's about.

-- 
http://selenic.com : development and support for Mercurial and Linux


