From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] use after free in AF_ROSE
Date: Wed, 10 Dec 2003 14:53:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210145326.6d1d9b81.davem@redhat.com>
References: <20031210100851.4b4a6927.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031210100851.4b4a6927.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 10:08:51 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Doing multiple protocol testing and get crashes with simple
> socket/close combo with AF_ROSE.  The problem is that it
> dereferences the socket in rose_release after it has already been
> freed by rose_destroy_socket.
> 
> This patch fixes that problem, and also uses sock_put to handle the
> case where rose_destroy_socket is called with sk_refcnt > 1 which
> might be possible if data comes in during close.

Applied, thanks a lot Stephen.
