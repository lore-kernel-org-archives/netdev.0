From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Kernel connector - userspace <-> kernelspace "linker".
Date: Tue, 21 Sep 2004 13:22:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095769354.30743.64.camel@localhost.localdomain>
References: <1095331899.18219.58.camel@uganda>
	 <20040921124623.GA6942@uganda.factory.vocord.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20040921124623.GA6942@uganda.factory.vocord.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2004-09-21 at 13:46, Evgeniy Polyakov wrote:
> Connector driver adds possibility to connect various agents using
> netlink based network.
> One must register callback and identificator. When driver receives
> special netlink message with appropriate identificator, appropriate
> callback will be called.

Looks sane enough to me - and it seems to fit the mentality d-bus and
HAL want to have. 

Alan

ps: only trivial item (and really trivial) is that the printk messages
should be "waiting for %s".
