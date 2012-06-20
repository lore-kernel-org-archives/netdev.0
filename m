From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH -v1 1/3] usbnet: clear OPEN flag in failure path
Date: Wed, 20 Jun 2012 09:44:07 +0200
Message-ID: <201206200944.07299.oneukum@suse.de>
References: <1340176553-32225-1-git-send-email-ming.lei@canonical.com> <1340176553-32225-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51950 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049Ab2FTHoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 03:44:08 -0400
In-Reply-To: <1340176553-32225-2-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 20. Juni 2012, 09:15:51 schrieb Ming Lei:
> Without clearing OPEN flag in failure path, runtime or system resume
> may submit interrupt/rx URB and start tx queue mistakenly on a
> interface in DOWN state.
> 
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
Acked-by: Oliver Neukum <oneukum@suse.de>
