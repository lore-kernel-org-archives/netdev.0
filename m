From: "David S. Miller" <davem@redhat.com>
Subject: Re: comment on [NET]: Delete support for old-style protocols, no
 longer necessary.
Date: Tue, 7 Oct 2003 11:52:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007115244.14a887ed.davem@redhat.com>
References: <1065551829.2340.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@nuts.ninka.net, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1065551829.2340.9.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Oct 2003 11:37:09 -0700
Joe Perches <joe@perches.com> wrote:

> -       void                    *af_packet_priv;
> +       struct sock             *sk;	/* appropriate comment: socket copy? */

AF_PACKET is the only user of this private field, and
I want people to be aware of this and not try to use it
for other stuff.

Nobody else can use it for something different, the code
in net/core/dev.c does specific things when it's non-NULL
knowing that this non-NULL value means that it's an
AF_PACKET packet_type being passed to it.

So we won't make your suggested change.
