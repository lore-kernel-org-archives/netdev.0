From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Mon, 17 Sep 2012 10:04:46 +0200
Message-ID: <2236952.YSZj5xxzHO@linux-lqwf.site>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fink Dmitry <finik@ti.com>, Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58613 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560Ab2IQIGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 04:06:18 -0400
In-Reply-To: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 16 September 2012 01:48:16 Ming Lei wrote:

Hi,

> Currently only very few usbnet devices support the traffic based
> runtime PM, eg. wake up devices if there are packets to be transmitted.
> 
> For the below situation, it should make sense to runtime suspend usbnet
> device to save power:
>         
>         - after network link becomes down

Basically cool design, but it raises two fundamental questions
and some detail questions.

> This patch implements the runtime PM triggered by network link change
> event, and it works basically on asix usbnet device after a simple
> runtime PM test.

1) Does it actually save power? You are constantly waking up a CPU.
>From that perspective it is possible that leaving on the ethernet is actually
better in terms of power. Only measurements can answer that question.

2) Do we have many devices that would be serviced with this approach?

	Regards
		Oliver
