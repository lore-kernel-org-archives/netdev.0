From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] memory leak in irda/sa1100_ir.c
Date: Fri, 10 Oct 2003 00:01:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010000119.4a3017e0.davem@redhat.com>
References: <20031009093752.01a374bc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031009093752.01a374bc.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Oct 2003 09:37:52 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This driver seems confused about what get done for it on module exit.
> It needs to free the network device it created.

Applied, thanks Stephen.
