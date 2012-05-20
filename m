From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] USB: qmi_wwan: Add ZTE (Vodafone) K3765-Z
Date: Sun, 20 May 2012 16:59:23 -0400 (EDT)
Message-ID: <20120520.165923.337410899962787130.davem@davemloft.net>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
	<1337502518-1444-2-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ajb@spheresystems.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337502518-1444-2-git-send-email-ajb@spheresystems.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
