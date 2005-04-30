From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Sat, 30 Apr 2005 01:37:55 +0100
Message-ID: <1114821473.24687.404.camel@localhost.localdomain>
References: <E1DRFqC-00028H-Qi@tigger>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Broadbent <markb@wetlettuce.com>
In-Reply-To: <E1DRFqC-00028H-Qi@tigger>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2005-04-28 at 21:42, Mark Broadbent wrote:
> The interrupt handling code in the tulip network driver appears to use a non 
> IRQ safe spinlock in an interrupt context.  The following patch should correct 
> this.

In what situations is this code path executed outside the IRQ handler ?
