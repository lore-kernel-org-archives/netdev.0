From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix module netproto alias for bluetooth
Date: Wed, 10 Dec 2003 15:59:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210155941.300b68ba.davem@redhat.com>
References: <20031210155836.1c12d56a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, rusty@rustcorp.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031210155836.1c12d56a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 15:58:36 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> In 2.6.0-test11 the net-pf-31 alias gets associated with the bnep module
> rather than the bluetooth module that actually handles the protocol.
> It is mostly works because bnep depends on bluetooth so it gets loaded.

Good catch, patch applied.

Thanks.
