From: James Morris <jmorris@intercode.com.au>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Mon, 21 Oct 2002 23:46:24 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210212342070.29133-100000@blackbird.intercode.com.au>
References: <27964.1035199084@passion.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <27964.1035199084@passion.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Oct 2002, David Woodhouse wrote:

>  1. I appear to need CAP_NET_ADMIN to bind to the netlink groups which give
> 	me this  information. I can poll for it just fine, but need 
> 	elevated privs to be notified. Why is this, and is there a workaround?

Andi Kleen implemented a simple and effective workaround this for 2.4
which has gone into the tree (see netlink_set_nonroot() in rtnetlink.c).  

Another more complicated solution was partially developed for 2.5, but is
unlikely to make it in by Halloween.


- James
-- 
James Morris
<jmorris@intercode.com.au>
