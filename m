From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 16/16] rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 23:07:27 +0000
Message-ID: <26069.1415920047@warthog.procyon.org.uk>
References: <546528BF.5040902@gmail.com> <1415906662-4576-17-git-send-email-bobby.prani@gmail.com> <1415906662-4576-1-git-send-email-bobby.prani@gmail.com> <24601.1415911646@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546528BF.5040902@gmail.com>
Content-ID: <26068.1415920047.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pranith Kumar <bobby.prani@gmail.com> wrote:

> OK. Should I send in a patch removing these barriers then?

No.  There need to be stronger barriers, at least in some of the cases.
circular-buffers.txt details what is required, but not all of the cases match
the pattern there, so it needs a bit more consideration.

David
