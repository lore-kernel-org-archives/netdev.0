From: "David S. Miller" <davem@redhat.com>
Subject: Re: old NLMSG_OK fix
Date: Sun, 27 Jun 2004 20:51:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040627205133.11d37f0c.davem@redhat.com>
References: <20040531160427.GA19581@lst.de>
	<20040627171552.GA2797@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040627171552.GA2797@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Jun 2004 19:15:52 +0200
Christoph Hellwig <hch@lst.de> wrote:

> http://oss.sgi.com/projects/netdev/archive/2000-09/msg00001.html

It works because there is always 16 bytes of scratch at the end of an
SKB more than was allocated for the actual data.  So blindly deref'ing
the nlmsg_len value is fine here.

There is no danger for OOPS's or kernel corruption.

I believe I responded exactly like this the last time this
patch was presented.
