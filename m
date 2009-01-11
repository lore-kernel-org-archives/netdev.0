From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SIS900 show warning if bogus MAC address
Date: Sun, 11 Jan 2009 04:04:55 -0800 (PST)
Message-ID: <20090111.040455.260477454.davem@davemloft.net>
References: <20090111084504.GB12226@brownhat.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: venza@brownhat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbZAKMEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 07:04:55 -0500
In-Reply-To: <20090111084504.GB12226@brownhat.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Venzano <venza@brownhat.org>
Date: Sun, 11 Jan 2009 09:45:04 +0100

> The attached patch modifies the sis900 driver to show a warning at boot
> or module load time to show a message when a null MAC address
> (00:00:00:00:00:00) is read from the the hardware.
> This seems to happen with newer usage of the sis900 chipset, since this
> never came up before.
> 
> Signed-off-by: Daniele Venzano <venza@brownhat.org>

Choose a random mac address, as other drivers do in this
situation, so that the user ends up with a usable interface.
