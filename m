From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] count tg3 rx_discards stat for /proc/net/dev
Date: Wed, 19 May 2004 21:16:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040519211603.0e2d5e73.davem@redhat.com>
References: <40A1AFD8.D5593759@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <40A1AFD8.D5593759@melbourne.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 May 2004 15:02:16 +1000
Greg Banks <gnb@melbourne.sgi.com> wrote:

> This small patch makes the rx_discards stat count towards the receive
> error count visible in /proc/net/dev and thus in the output of ifconfig.
> This stat is rarely non-zero unless you use multiple cards on the same
> PCI bus under heavy load; but when it does happen you really want to
> know about it.

I agree, nice patch, applied.
