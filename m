From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Remove MOD_* from LAPB
Date: Sat, 19 Jul 2003 21:44:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030719214458.2ea87a94.davem@redhat.com>
References: <20030718133211.1c7ed08d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eis@baty.hanse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030718133211.1c7ed08d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jul 2003 13:32:11 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The MOD_INC and MOD_DEC in lapb are no longer necessary in 2.6 since
> the module subsystem will not allow lapb to be unloaded as long as a module
> that is referencing the symbols (lapb_register/lapb_unregister) is loaded.
> 
> The lapb parameter block does have callback's so it is up to the caller
> to correctly unregister on module exit; and looking at the existing code
> it does do that.

Applied, thanks.
