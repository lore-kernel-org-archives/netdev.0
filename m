From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.9-rc3] dev_close: use of netif_poll_disable
Date: Sun, 3 Oct 2004 15:02:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003150229.0eb4fa67.davem@redhat.com>
References: <20041002202805.GA16870@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041002202805.GA16870@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Oct 2004 22:28:05 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Use of identical (comment included) netif_poll_disable().
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

It's not identical.  netif_poll_disable() actually sets the
__LINK_STATE_RX_SCHED bit when it finally sees it clear.

Whereas this code in net/core/dev.c is just waiting for it
to clear.
