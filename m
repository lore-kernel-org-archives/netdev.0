From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: fix for the 'invalid frame length' messages
Date: Thu, 02 Apr 2009 01:20:32 -0700 (PDT)
Message-ID: <20090402.012032.67869929.davem@davemloft.net>
References: <20090330094459.GC9849@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754145AbZDBIUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:20:44 -0400
In-Reply-To: <20090330094459.GC9849@raptor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>
Date: Mon, 30 Mar 2009 11:44:59 +0200

> Some devices cannot send very short usb transfers. To get around this the
> firmware adds a known pattern and flags the driver that it should check for
> this pattern on short transfers. This flag was not taken into account by
> the driver.
> 
> Signed-off-by: Jan Dumon <j.dumon@option.com>

These patches do not apply cleanly, please respin them against the
current sources.
