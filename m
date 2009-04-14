From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix velocity_intr() in the VIA Velocity driver to have
 the right return type
Date: Tue, 14 Apr 2009 14:20:14 -0700 (PDT)
Message-ID: <20090414.142014.53605891.davem@davemloft.net>
References: <20090414155325.27548.90325.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755617AbZDNVUe@vger.kernel.org>
In-Reply-To: <20090414155325.27548.90325.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 14 Apr 2009 16:53:25 +0100

> Fix velocity_intr() in the VIA Velocity driver to have the right return type.
> As it stands, it returns the right values, but as type int, not type
> irqreturn_t.  This leads to the following compiler warning:
> 
>   CC      drivers/net/via-velocity.o
> drivers/net/via-velocity.c: In function 'velocity_open':
> drivers/net/via-velocity.c:1924: warning: passing argument 2 of 'request_irq' from incompatible pointer type
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Already fixed in net-2.6
