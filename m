From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug#267342: kernel-image-2.6.8-1-686-smp: TCP/IP strangeness in
 2.6.8
Date: Wed, 25 Aug 2004 16:05:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825160532.78235ffd.davem@redhat.com>
References: <20040822021929.E9D04212D@maus.private.neotoma.org>
	<20040825144808.GA10396@lst.de>
	<412D0152.1040509@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, kddaniel@private.neotoma.org, 267342@bugs.debian.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <412D0152.1040509@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Aug 2004 14:14:58 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Christoph Hellwig wrote:
> > Could it be possible OpenBSD doesn't properly deal with the tcp window
> > scaling changes in 2.6.8? (http://lwn.net/Articles/92727/)
> 
> Unless there is present in the path one of those broken
> routers (mangling the window scale option), it's likely
> something else.

It was found to in fact be OpenBSD, this bug has been well known
for some time too.  See followups made in this thread.
