From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] consolidate skb delivery
Date: Fri, 3 Oct 2003 00:11:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003001128.587ac102.davem@redhat.com>
References: <20031002102133.7285b5ee.shemminger@osdl.org>
	<20031002192546.GA29673@wotan.suse.de>
	<20031002124345.7b34bf24.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031002124345.7b34bf24.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Oct 2003 12:43:45 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Thu, 2 Oct 2003 21:25:46 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Are there even any old style protocols left? If not you could just make
> > it BUG() 
> > 
> 
> bpqether,lapbether,ipconfig, and econet are still old style.

I would suggest we eliminate support for old style protocols
now.  We can do that by making the ptype registry in net/core/dev.c
fail if the thing being registered is old-style.

I'll code this up.

If we don't kill support for old-style protocols now, we can end up
being stuck supporting it throughout 2.6.x which I'd like to avoid.

I'll apply Stephen's patch here.
