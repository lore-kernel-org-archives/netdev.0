From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/core/flow.c cpu handling?
Date: Mon, 3 Nov 2003 14:55:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031103145539.17f3ba01.davem@redhat.com>
References: <20031102062345.A472E2C0CD@lists.samba.org>
	<20031101225050.4de96a8b.davem@redhat.com>
	<20031103151145.A29287@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, anton@samba.org, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20031103151145.A29287@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Nov 2003 15:11:45 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Nov 01, 2003 at 10:50:50PM -0800, David S. Miller wrote:
> > 
> > Very likely, the code is how it is in order to make the
> > 2.4.x backport of this code and the 2.6.x version as
> > similar as humanly possible.
> 
> Well, the current code is wrong for 2.6 and breaks badly for machines
> with more than 32/64 cpus.

I totally understand, I am in no way trying to justify what
the code is doing.
