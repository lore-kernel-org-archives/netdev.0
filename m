From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] USB: qmi_wwan: Make forced int 4 whitelist generic
Date: Sun, 20 May 2012 16:59:14 -0400 (EDT)
Message-ID: <20120520.165914.334514690365378881.davem@davemloft.net>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ajb@spheresystems.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Bird <ajb@spheresystems.co.uk>
Date: Sun, 20 May 2012 09:28:36 +0100

> Change the forced interface 4 whitelist to use the generic shared
> binder instead of the Gobi specific one. Certain ZTE devices
> (K3520-Z & K3765-Z) don't work with the Gobi version, but function
> quite happily with the generic. This has been tested with the following
> devices:
> K3520-Z
> K3565-Z
> K3765-Z
> K4505-Z
> It hasn't been tested with the ZTE MF820D, which is the only other
> device that uses this whitelist at present. Although Bjorn doesn't
> expect any problems, any testing with that device would be appreciated.
> 
> Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>

Applied to net-next.
