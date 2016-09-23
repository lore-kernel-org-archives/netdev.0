From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 08/15] rxrpc: Fix call timer
Date: Fri, 23 Sep 2016 19:21:20 +0100
Message-ID: <6113.1474654880@warthog.procyon.org.uk>
References: <9efafc3e-5f19-598c-ee0c-def748eeb78a@cogentembedded.com> <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk> <147464377267.5090.12222734463447533990.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9efafc3e-5f19-598c-ee0c-def748eeb78a@cogentembedded.com>
Content-ID: <6112.1474654880.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> > +		if (call->timer.expires != t || !timer_pending(&call->timer)) {
> >  			mod_timer(&call->timer, t);
> >  		}
> 
>    CodingStyle: {} not needed now.

See patch 11.

David
