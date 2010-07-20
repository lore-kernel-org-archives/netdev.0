From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] bnx2: Call pci_enable_msix() with actual
 number of vectors.
Date: Mon, 19 Jul 2010 20:31:12 -0700 (PDT)
Message-ID: <20100719.203112.73342511.davem@davemloft.net>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
	<1279584905-15084-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, leitao@linux.vnet.ibm.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758217Ab0GTDa4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 23:30:56 -0400
In-Reply-To: <1279584905-15084-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 19 Jul 2010 17:15:03 -0700

> Based on original patch by Breno Leit=E3o <leitao@linux.vnet.ibm.com>=
=2E
>=20
> Allocate the actual number of vectors and make use of fewer vectors
> if pci_enable_msix() returns > 0.  We must allocate one additional
> vector for the cnic driver.
>=20
> Cc: Breno Leit=E3o <leitao@linux.vnet.ibm.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
