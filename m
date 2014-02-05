From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:phy:dp83640: Do not hardcode timestamping event
 edge
Date: Tue, 04 Feb 2014 20:08:07 -0800 (PST)
Message-ID: <20140204.200807.959228526908395245.davem@davemloft.net>
References: <1391438210-21941-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbaBEEII convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:08:08 -0500
In-Reply-To: <1391438210-21941-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Mon,  3 Feb 2014 15:36:50 +0100

> Currently the external timestamping code it hardcoded to use
> the rising edge even though the hardware has configurable event
> edge detection. This patch change the code to use falling edge
> detection if PTP_FALLING_EDGE is set in the user supplied flags.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied.
