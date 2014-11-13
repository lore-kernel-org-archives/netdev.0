From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 16/16] rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 20:47:26 +0000
Message-ID: <24601.1415911646@warthog.procyon.org.uk>
References: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com> <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list),
	paulmck@linux.vnet.ibm.com
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com>
Content-ID: <24600.1415911646.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pranith Kumar <bobby.prani@gmail.com> wrote:

> Recently lockless_dereference() was added which can be used in place of
> hard-coding smp_read_barrier_depends(). The following PATCH makes the change.

Actually, the use of smp_read_barrier_depends() is wrong in circular
buffering.  See Documentation/circular-buffers.txt

David
