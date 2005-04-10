From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bug 4467] New: Debug: sleeping function called from
 invalid context at mm/slab.c:2090
Date: Sun, 10 Apr 2005 14:47:05 -0700
Message-ID: <20050410144705.3b8ace07.davem@davemloft.net>
References: <20050410134934.0bf9d6b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, avvisi@spalletti.it
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050410134934.0bf9d6b8.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 10 Apr 2005 13:49:34 -0700
Andrew Morton <akpm@osdl.org> wrote:

> 
> proto_register() is doing kmem_cache_create() inside write_lock().

Didn't you integrate Arnaldo's patch to fix this into -mm?
I was certain I got an ACK email back from your -mm automatic
thingy.
