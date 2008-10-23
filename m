From: Sven Hartge <sven@svenhartge.de>
Subject: Re: [PATCH] via-velocity: earlier name allocation
Date: Thu, 23 Oct 2008 09:29:34 +0200
Message-ID: <490027DE.3000409@svenhartge.de>
References: <alpine.DEB.2.00.0810230114180.17076@ds9.feds.ath.cx> <20081022170422.7851ea9a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenhartge.de ([81.169.140.245]:54663 "EHLO svenhartge.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbYJWH3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 03:29:40 -0400
In-Reply-To: <20081022170422.7851ea9a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:


> NAK
>=20
> There is nothing to prevent that device name from being allocated by =
another device
> at that point.  The correct fix is to not use dev->name until after r=
egistering
> the network device.  Change the order of registration or pass dev_dri=
ver_string(&pdev->dev)
> instead of dev->name to velocity_get_options

=46ine with me. This was just the hint I was looking for. If you don't
mind, I will mail a new patch for this case later.

S=B0

