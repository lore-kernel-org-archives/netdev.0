From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BUG] alignment problem in net/core/flow.c:flow_key_compare
Date: Thu, 18 Mar 2004 20:21:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318202111.68cf8dfe.davem@redhat.com>
References: <20040318162903.59192d13.akpm@osdl.org>
	<20040319.115511.32395995.yoshfuji@linux-ipv6.org>
	<20040318185940.45108d6a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, mru@kth.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040318185940.45108d6a.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 18:59:40 -0800
Andrew Morton <akpm@osdl.org> wrote:

> >  -};
> >  +} __attribute__((__aligned__(FLOWI_ALIGN_BYTES)));
> >  
> 
> Why not simply
> 
> >  +} __attribute__((__aligned__(BITS_PER_LONG/8)));

Works for me :-)
