From: James Morris <jmorris@redhat.com>
Subject: Re: 2.6.9-rc1-mm5: TCP oopses
Date: Mon, 13 Sep 2004 23:04:24 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409132303160.22907-100000@thoron.boston.redhat.com>
References: <20040913190858.12544431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@osdl.org, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040913190858.12544431.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004, David S. Miller wrote:

> I think I fixed this one yesterday.  Callers of tcp_fragment()
> in tcp_output.c were not accounting packets correctly.  I
> believe this is what will fix it, and this is in Linus's
> tree already.

This patch is also in -mm5 (linus.patch), and the oopses go away when I 
back it out.

> I guess you have an e1000 in this box? :)

Yes.


- James
-- 
James Morris
<jmorris@redhat.com>
