From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][SELINUX] 2/2 sock_create_lite()
Date: Fri, 7 May 2004 16:14:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040507161455.A31114@infradead.org>
References: <Xine.LNX.4.44.0405071043540.21372@thoron.boston.redhat.com> <Xine.LNX.4.44.0405071056300.21372-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Stephen Smalley <sds@epoch.ncsc.mil>,
        Chris Wright <chrisw@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, selinux@tycho.nsa.gov
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0405071056300.21372-100000@thoron.boston.redhat.com>; from jmorris@redhat.com on Fri, May 07, 2004 at 11:06:04AM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 07, 2004 at 11:06:04AM -0400, James Morris wrote:
> This patch adds a function sock_create_lite(), deprecating kernel-wide use
> of sock_alloc(), which has been made static to net/socket.c.

We're in the stable series and removing exported APIs there shoudn't happen.
Given that sock_alloc() is actually okay for every normal use I don't think
there's enough reason to remove it from the API.

> +int sock_create_lite(int family, int type, int protocol, struct socket **res)

Should probably be called __sock_create according to linux naming rules.
Also I guess you should actually call it from sock_create instead of
duplicating the code.
