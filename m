From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->xmit_lock_owner?
Date: Tue, 18 Feb 2003 16:02:41 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030218.160241.10142341.davem@redhat.com>
References: <20030218183306.GA31478@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: jgarzik@pobox.com
In-Reply-To: <20030218183306.GA31478@gtf.org>
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Tue, 18 Feb 2003 13:33:06 -0500

   It seems that dev_watchdog, among other places, does not assign a value
   to dev->xmit_lock_owner, when it takes the lock.
   
   I think this is a bug, but could be wrong ;-)

Not a bug, only pieces of the transmit path need to follow
this rule.  It's only meant to detect devices which have
been chained in a way which forms a loop during transmit.
