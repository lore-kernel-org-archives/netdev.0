From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next] rxrpc: Don't expose skbs to in-kernel users
Date: Fri, 02 Sep 2016 00:42:15 +0100
Message-ID: <15134.1472773335@warthog.procyon.org.uk>
References: <20160901.163942.2272956240456598007.davem@davemloft.net> <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk> <147257235952.6716.3613899854387213654.stgit@warthog.procyon.org.uk> <20160901.163832.1923741041602397930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901.163942.2272956240456598007.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Actually, reverted, this adds a new warning to the build:
> 
> net/rxrpc/recvmsg.c: In function ‘rxrpc_kernel_recv_data’:
> net/rxrpc/recvmsg.c:531:1: warning: label ‘need_more_data’ defined but not used [-Wunused-label]
>  need_more_data:
>  ^
> net/rxrpc/recvmsg.c:475:7: warning: unused variable ‘no_more’ [-Wunused-variable]
>   bool no_more;
>        ^

Yes.  I sent a second version.

David
