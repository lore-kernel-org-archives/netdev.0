From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 0/3] rxrpc: Tx length parameter
Date: Wed, 07 Jun 2017 22:11:03 +0100
Message-ID: <21315.1496869863@warthog.procyon.org.uk>
References: <149685280179.8474.3836343127280242150.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149685280179.8474.3836343127280242150.stgit@warthog.procyon.org.uk>
Content-ID: <21314.1496869863.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

>  (3) Introduce the RXRPC_TX_LENGTH cmsg.  This can be provided on the first
>      sendmsg() that contributes data to a client call request or a service
>      call reply.  If provided, the user must provide exactly that amount of
>      data or an error will be incurred.

I forgot to change struct rxrpc_send_params::tx_total_len from u64 to s64.
Will repost.

David
