From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] AF_RXRPC fixes
Date: Tue, 28 Jan 2014 18:05:44 -0800 (PST)
Message-ID: <20140128.180544.1357966891418521200.davem@davemloft.net>
References: <8672.1390928856@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	tim@electronghost.co.uk, khoroshilov@ispras.ru,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8672.1390928856@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 28 Jan 2014 17:07:36 +0000

> Here are some small AF_RXRPC fixes.
> 
>  (1) Fix a place where a spinlock is taken conditionally but is released
>      unconditionally.
> 
>  (2) Fix a double-free that happens when cleaning up on a checksum error.
> 
>  (3) Fix handling of CHECKSUM_PARTIAL whilst delivering messages to userspace.

Pulled, thanks David.
