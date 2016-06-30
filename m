From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 00/19] rxrpc: Improve conn/call lookup and fix call number generation
Date: Thu, 30 Jun 2016 15:22:47 +0100
Message-ID: <27525.1467296567@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Content-ID: <27524.1467296567.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sigh.

It seems I misunderstood the comment on read_seqbegin_or_lock() and failed to
initialise seq in rxrpc_find_service_conn_rcu().  For some reason my compiler
didn't notice, though Fengguang's magic compile farm did.

So, please ignore this version of the patchset and I'll post a new set.

David
