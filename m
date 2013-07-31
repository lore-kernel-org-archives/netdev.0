From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 0/4] USB & USBNET: loose DMA SG check and support usbnet
 DMA SG
Date: Wed, 31 Jul 2013 13:12:08 +0200
Message-ID: <1375269128.17175.8.camel@linux-fkkt.site>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56705 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755023Ab3GaLMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 07:12:13 -0400
In-Reply-To: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 18:51 +0800, Ming Lei wrote:
> Hi,
> 
> This patchset allows drivers to pass sg buffers which size can't be divided
> by max packet size of endpoint if the host controllers support this kind
> of sg buffers.

Cool. One question though. It makes sense to use sg only
if all elements are in memory capable of DMA. It seems to be possible
to have HCs which can do unlimited sg but are limited to 32bit DMA.

	Regards
		Oliver
