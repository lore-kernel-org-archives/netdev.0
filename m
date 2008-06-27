From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next] rndis_host: pass buffer length to rndis_command
Date: Fri, 27 Jun 2008 02:09:25 -0400
Message-ID: <48648415.9090602@garzik.org>
References: <20080618124011.11920.98218.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41236 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756394AbYF0GJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:09:29 -0400
In-Reply-To: <20080618124011.11920.98218.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Pass buffer length to rndis_command so that rndis_command can read full
> response buffer from device instead of max CONTROL_BUFFER_SIZE bytes.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> ---
> 
>  drivers/net/usb/rndis_host.c      |   14 +++++++-------
>  drivers/net/wireless/rndis_wlan.c |    4 ++--
>  include/linux/usb/rndis_host.h    |    3 ++-
>  3 files changed, 11 insertions(+), 10 deletions(-)

applied


