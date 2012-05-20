From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] USB: qmi_wwan: Add ZTE (Vodafone) K3765-Z
Date: Sun, 20 May 2012 16:59:36 -0400 (EDT)
Message-ID: <20120520.165936.1796496403682068067.davem@davemloft.net>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
	<1337502518-1444-2-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ajb@spheresystems.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756306Ab2ETVAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 17:00:51 -0400
In-Reply-To: <1337502518-1444-2-git-send-email-ajb@spheresystems.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Bird <ajb@spheresystems.co.uk>
Date: Sun, 20 May 2012 09:28:37 +0100

> Add the ZTE (Vodafone) K3765-Z to the whitelist. This requires the
> previous patch to make the whitelist with forced interface 4 generic
> or the device fails to initialise. After applying this patch and
> loading the Option driver without usb-modeswitch's bind all
> interfaces trick, a wwan0 net interface and /dev/cdc-wdm0 device
> file were created. Using Bjorn Mork's perl connection script a
> connection was made to a mobile network using QMI and the network
> interface's IPv4 address was configured OK.
> 
> Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>

Applied to net-next.
