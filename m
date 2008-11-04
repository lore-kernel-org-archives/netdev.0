From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] tg3: Allow WOL for phylib controlled Broadcom
 phys
Date: Mon, 03 Nov 2008 16:54:37 -0800 (PST)
Message-ID: <20081103.165437.02556544.davem@davemloft.net>
References: <1225751626.6190@xw6200>
	<2acbd3e40811031509q3d3005e5g9fedd842a1d08a52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	andy@greyhouse.net
To: afleming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbYKDAzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:55:02 -0500
In-Reply-To: <2acbd3e40811031509q3d3005e5g9fedd842a1d08a52@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andy Fleming" <afleming@gmail.com>
Date: Mon, 3 Nov 2008 17:09:34 -0600

> On Mon, Nov 3, 2008 at 4:13 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > This patch allows WOL to be enabled for Broadcom phys under phylib
> > control.  The only exception is the AC131, which has a completely
> > different register set.
> >
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Code to enable WOL sounds like the sort of thing we'd want in the PHY
> driver itself, rather than a manual setup done from the NIC driver.
> Clearly, we need support for WOL on both in order for it to work,
> though, so I can see two solutions off the top of my head:
 ...

I've applied Matt's patch, but I hope that you two will continue
the dialogue about this issue.
