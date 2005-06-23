From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 0/3] netpoll: support multiple netpoll clients per
 net_device
Date: Wed, 22 Jun 2005 22:06:33 -0700 (PDT)
Message-ID: <20050622.220633.34603084.davem@davemloft.net>
References: <17082.4037.875432.648439@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262376AbVFWFG4@vger.kernel.org>
To: jmoyer@redhat.com
In-Reply-To: <17082.4037.875432.648439@segfault.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Moyer <jmoyer@redhat.com>
Date: Wed, 22 Jun 2005 21:26:29 -0400

> This patch series restores the ability to register multiple netpoll clients
> against the same network interface.  To this end, I created a new structure:
 ...
> I have tested this by registering two netpoll clients, and verifying that
> they both function properly.  The clients were netconsole, and a quick
> module I hacked together to send console messages to syslog.  I issued
> sysrq-h, sysrq-m, and sysrq-t's both by echo'ing to /proc/sysrq-trigger and
> by hitting the key combination on the keyboard.  This verifies that the
> modules work both inside and out of interrupt context.

This all looks great.  I've applied all 3 patches.

Thanks for taking care of this Jeff.
