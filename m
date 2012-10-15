From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v1 00/11] usbnet: usb_control_msg cleanup
Date: Mon, 15 Oct 2012 08:30:58 +0200
Message-ID: <5690496.KbQ6sjjSnW@linux-lqwf.site>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49805 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab2JOGcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2012 02:32:46 -0400
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 October 2012 20:39:18 Ming Lei wrote:
> Hi,
> 
> This patch set introduces 3 helpers for handling usb read, write
> and write_async command, and replaces the low level's implemention
> with the generic ones.
> 
> This patchset is a cleanup and about 300 lines code can be saved.
> 
> Also, the patchset fixes problem of DMA on buffer embedded inside
> one dynamic allocated buffer, and such usages can be found
> in cdc-ncm, sierra_net, mcs7830 and asix drivers.
> 
> v1:
> 	- drop previous patch 12, and let net/core handle
> 	runtime PM in ioctl path

Acked-by: Oliver Neukum <oneukum@suse.de>
