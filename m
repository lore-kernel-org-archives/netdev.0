From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and
 provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 10:32:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824103252.1b593e68.davem@redhat.com>
References: <20040824094952.GF21073@postel.suug.ch>
	<E1BzYMJ-000208-00@gondolin.me.apana.org.au>
	<20040824162501.GI21296@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040824162501.GI21296@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 18:25:01 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Herbert Xu <E1BzYMJ-000208-00@gondolin.me.apana.org.au> 2004-08-24 20:16
> > Please think about the meaning of the value.  Is anyone going to have a queue
> > bigger than 2^32?
> > 
> > And if the answer is yes, then please use u64.
> 
> Here's a new patch with all discussed changes integrated. I don't have enough
> cycles to split it all up again.

This patch only contained net/core/rtnetlink.c changes, where is
the rest?
