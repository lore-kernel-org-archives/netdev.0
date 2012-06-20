From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH -v1 3/3] usbnet: handle remote wakeup asap
Date: Wed, 20 Jun 2012 09:46:06 +0200
Message-ID: <201206200946.06380.oneukum@suse.de>
References: <1340176553-32225-1-git-send-email-ming.lei@canonical.com> <1340176553-32225-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52086 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182Ab2FTHqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 03:46:06 -0400
In-Reply-To: <1340176553-32225-4-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 20. Juni 2012, 09:15:53 schrieb Ming Lei:
> If usbnet is resumed by remote wakeup, generally there are
> some packets comming to be handled, so allocate and submit
> rx URBs in usbnet_resume to avoid delays introduced by tasklet.
> Otherwise, usbnet may have been runtime suspended before the
> usbnet_bh is executed to schedule Rx URBs.
> 
> Without the patch, usbnet can't recieve any packets from peer
> in runtime suspend state if runtime PM is enabled and
> autosuspend_delay is set as zero.
> 
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
Acked-by: Oliver Neukum <oneukum@suse.de>
