From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Do not use legacy PCI power management
Date: Fri, 31 Dec 2010 10:15:21 -0800
Message-ID: <20101231101521.598d41c6@s6510>
References: <201012261944.32517.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Linux-pm mailing list" <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32989 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994Ab0LaSPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Dec 2010 13:15:24 -0500
In-Reply-To: <201012261944.32517.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Dec 2010 19:44:32 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The sky2 driver uses the legacy PCI power management, so it has to do
> some PCI-specific things in its ->suspend() and ->resume() callbacks,
> which isn't necessary and should better be done by the PCI
> sybsystem-level power management code.  Moreover, it uses
> device_set_wakeup_enable() incorrectly (that function should be
> used when the WoL setting is changed rather than during suspend).
> 
> Convert sky2 to the new PCI power management framework and make it
> let the PCI subsystem take care of all the PCI-specific aspects of
> device handling during system power transitions.
> 
> Tested on a desktop machine with a Marvell 88E8056 PCI-E adapter.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Tested on 88E8055 (laptop), my desktop machines have video issues and
won't suspend/resume.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

