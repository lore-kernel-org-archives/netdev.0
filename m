From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Eliminate MOD_ from wanrouter
Date: Sat, 19 Jul 2003 21:48:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030719214843.0dbf5f3c.davem@redhat.com>
References: <20030718133512.434b1e70.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030718133512.434b1e70.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jul 2003 13:35:12 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Wan router register/unregister doesn't need MOD_INC/MOD_DEC because it
> can't be unloaded as long as it's symbols are in use by the calling module.

Applied, thanks.
