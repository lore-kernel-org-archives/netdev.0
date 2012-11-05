From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: connector and netlink_broadcast (semop failed for cookie ...)
Date: Tue, 6 Nov 2012 01:11:59 +0400
Message-ID: <20121105211159.GA4894@ioremap.net>
References: <509816A8.70005@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <509816A8.70005@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Mon, Nov 05, 2012 at 08:42:32PM +0100, Alexander Holler (holler@ahsoftware.de) wrote:
> Could it be the case that cn_netlink_send() has to ignore the same
> return codes as done in kobject_uevent_env()? Or maybe the users of
> cn_netlink_send() have to ignore them?

We just do not know what to do with that error.
Pretty much it means nothing can be done about it.
There is no recovery path, no collection and resend, since it may lead to dos.

Its like knowing that udp packet get lost, but you do not have enough
buffer space to save it and block. Actually there is no buffer at all.
Kind of missed interrupt.

-- 
	Evgeniy Polyakov
