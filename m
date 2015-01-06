From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next v1 0/3] net: fec: add Wake-on-LAN support
Date: Tue, 6 Jan 2015 19:21:42 +0800
Message-ID: <20150106112140.GK24511@dragon>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
 <20141231.130727.1660985956287926494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: b38611@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43250 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbAFLWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:22:02 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so30805658pad.37
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 03:22:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141231.130727.1660985956287926494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 01:07:27PM -0500, David Miller wrote:
> From: Fugang Duan <b38611@freescale.com>
> Date: Wed, 24 Dec 2014 17:30:38 +0800
> 
> > The patch series enable FEC Wake-on-LAN feature for i.MX6q/dl and i.MX6SX SOCs.
> > FEC HW support sleep mode, when system in suspend status with FEC all clock gate
> > off, magic packet can wake up system. For different SOCs, there have special SOC
> > GPR register to let FEC enter sleep mode or exit sleep mode, add these to platform
> > callback for driver' call.
> > 
> > Patch#1: add WOL interface supports.
> > Patch#2: add SOC special sleep of/off operations for driver's sleep callback.
> > Patch#3: add magic pattern support for devicetree.
> 
> Series applied, thanks.

I'm not sure you want to take the last two patches.  Doing so will
likely causes merge conflict between net and arm-soc tree.

Shawn
