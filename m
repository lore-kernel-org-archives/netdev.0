From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TG3: fiber hw autoneg bounces
Date: Mon, 1 Nov 2004 17:27:12 -0800
Message-ID: <20041101172712.55e97846.davem@davemloft.net>
References: <4182B6A7.90700@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian.Somers@Sun.COM, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Waychison <Michael.Waychison@Sun.COM>
In-Reply-To: <4182B6A7.90700@sun.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 17:31:19 -0400
Mike Waychison <Michael.Waychison@Sun.COM> wrote:

> I've traced it to be caused by the tg3_timer 1 second work noticing that
> MAC_STATUS_LNKSTATE_CHANGED was set, which driver would see as the link
> going down.
> 
> Upon further inspection, it appears that we don't wait long enough
> between setting SG_DIG_CTRL and reading the SG_DIG_STATUS for the result.

How come the bcm5700 Broadcom driver gets away without this
incredibly huge delay?  The touching of the device is absolutely
identical in the tg3 driver to what Broadcom's bcm5700 code
is doing.

I'll apply the patch for now though...
