From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3 3/4] USBNET: support DMA SG
Date: Tue, 06 Aug 2013 14:08:07 +0200
Message-ID: <1375790887.1676.22.camel@linux-fkkt.site>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	 <1375750370-18194-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Alan Stern <stern@rowland.harvard.edu>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40228 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756083Ab3HFMIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 08:08:12 -0400
In-Reply-To: <1375750370-18194-4-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 08:52 +0800, Ming Lei wrote:
> This patch introduces support of DMA SG if the USB host controller
> which usbnet device is attached to is capable of building packet from
> discontinuous buffers.
> 
> The patch supports passing the skb fragment buffers to usb stack directly
> via urb->sg.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Grant Grundler <grundler@google.com>
> Cc: Freddy Xin <freddy@asix.com.tw>
> Cc: Oliver Neukum <oneukum@suse.de>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
Acked-by: Oliver Neukum <oneukum@suse.de>
