From: David Howells <dhowells@redhat.com>
Subject: Re: [GIT PULL] AF_RXRPC fixes and development
Date: Fri, 28 Feb 2014 11:02:44 +0000
Message-ID: <18115.1393585364@warthog.procyon.org.uk>
References: <20140226.140053.115418122553568429.davem@davemloft.net> <12143.1393436505@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, tim@electronghost.co.uk,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140226.140053.115418122553568429.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> > Here are some AF_RXRPC fixes (to tag rxrpc-20140226):
> 
> You really need to post the patch series along with the pull
> request so that netdev can review your changes.

Okay.  Fengguang's magic box reported some warnings with one of the patches,
which I'll get fixed up first.  Turns out it doesn't like a bunch of __be
values being added together to make a hash value without casts:-/

David
