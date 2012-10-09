From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 12/12] usbnet: make device out of suspend before calling usbnet_read/write_cmd
Date: Tue, 09 Oct 2012 10:50:05 +0200
Message-ID: <2913414.gCAxlQ38lG@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <1349160684-6627-13-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33369 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115Ab2JIIvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 04:51:48 -0400
In-Reply-To: <1349160684-6627-13-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 October 2012 14:51:23 Ming Lei wrote:
> This patche gets the runtime PM reference count before calling
> usb_control_msg, and puts it after completion of the
> usb_control_msg, so that the usb control message can always be
> sent to one active device.

This is awkward to use in suspend()/resume()
Could you make both versions available?

	Regards
		Oliver
