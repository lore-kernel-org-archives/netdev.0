From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 13:29:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916132923.0ac971f8.davem@davemloft.net>
References: <20040916132856.GA27293@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040916132856.GA27293@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 15:28:56 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Fixes slab corruption in cbq_destroy. cbq_destroy_filters and
> qdisc_put_rtab(q->link.R_tab) are already called in cbq_destroy_class.
> The latter lead to a slab corruption due to repeated freeing of
> q->link.R_tab because q->link is part of q->classes. Problem introduced
> in 1.21.

Good catch, applied.
