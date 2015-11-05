From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: call sk->sk_data_ready() on accept()
Date: Wed, 04 Nov 2015 22:03:32 -0500 (EST)
Message-ID: <20151104.220332.1882923396348027768.davem@davemloft.net>
References: <1446641922-32243-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thellstrom@vmware.com, asarwade@vmware.com,
	jhansen@vmware.com, linux-kernel@vger.kernel.org
To: stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446641922-32243-1-git-send-email-stefanha@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Wed,  4 Nov 2015 12:58:42 +0000

> When a listen socket enqueues a connection for userspace to accept(),
> the sk->sk_data_ready() callback should be invoked.  In-kernel socket
> users rely on this callback to detect when incoming connections are
> available.
> 
> Currently the sk->sk_state_change() callback is invoked by
> vmci_transport.c.  This happens to work for userspace applications since
> sk->sk_state_change = sock_def_wakeup() and sk->sk_data_ready =
> sock_def_readable() both wake up the accept() waiter.  In-kernel socket
> users, on the other hand, fail to detect incoming connections.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied.
