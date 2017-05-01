From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Initialise init_net.count to 1
Date: Sun, 30 Apr 2017 22:32:30 -0400 (EDT)
Message-ID: <20170430.223230.1494589195975312075.davem@davemloft.net>
References: <149332922378.28919.11614036268701178135.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149332922378.28919.11614036268701178135.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 27 Apr 2017 22:40:23 +0100

> Initialise init_net.count to 1 for its pointer from init_nsproxy lest
> someone tries to do a get_net() and a put_net() in a process in which
> current->ns_proxy->net_ns points to the initial network namespace.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
