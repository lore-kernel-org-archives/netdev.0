From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Wed, 18 Aug 2004 14:56:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818145630.2bdd0b24.davem@redhat.com>
References: <20040817100755.A20489@infradead.org>
	<Xine.LNX.4.44.0408170933240.9207-100000@dhcp83-76.boston.redhat.com>
	<20040817150739.A22153@infradead.org>
	<20040818042800.GC1007@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20040818042800.GC1007@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Aug 2004 01:28:00 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Agreed, not because it is "not important", but because panicing at module
> load, even in very rare cases is unnacceptable IMHO.

I think even non-modular cases should fail gracefully.
If the ipv4 one fails, no ipv4 networking sorry. :-)
