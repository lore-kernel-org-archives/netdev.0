From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug#251215: kernel-image-2.6.6-1-k7: pppd locks up, cannot be
 killed, during ppp shutdown
Date: Sat, 29 May 2004 12:51:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529125153.5f2df6ad.davem@redhat.com>
References: <20040529051736.GA11303@gondor.apana.org.au>
	<E1BU2WC-0003nd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, debian.bugs@kepier.clara.net,
        251215@bugs.debian.org, shemminger@osdl.org, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BU2WC-0003nd-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 May 2004 22:00:52 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a minimal fix for this problem.

Wouldn't it be easier just to move the "list_empty(&net_todo_list)"
check to be inside the net_todo_run_mutex semaphore?
