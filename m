From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 9/9] Avoid warning on CONNTRACK_STAT_INC in
 destroy_conntrack()
Date: Thu, 28 Oct 2004 16:49:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164956.2c340c1b.davem@davemloft.net>
References: <200410280721.i9S7Ll908021@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Ll908021@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:48 -0700
akpm@osdl.org wrote:

> From: Rusty Russell <rusty@rustcorp.com.au>
> 
> ip_conntrack_put can be called in any context in theory: in particular,
> MASQUERADE will can call it (via ip_ct_selective_cleanup) when an interface
> comes up with a different address.
> 
> Move the CONNTRACK_STAT_INC inside the lock: it needs preemption disabled.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
