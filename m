From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netem - distribution table fixes.
Date: Mon, 30 Aug 2004 16:55:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830165551.69979bfb.davem@redhat.com>
References: <20040830135717.1f4a3af0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040830135717.1f4a3af0@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 13:57:17 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix some issues with netem. 
>  * fix memory link in q_destroy where distribution table not freed
>  * fix math error in tabledist that made it work for only small values
>  * change API for distribution table so scaling factor is constant and
>    table size is determined by looking at the rtnetlink payload size.
>    this is faster and simpler. Since haven't actually released the tools to load
>    the table yet, this is the chance to get it right ;-)
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks good, applied.
