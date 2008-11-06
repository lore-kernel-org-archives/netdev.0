From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes for 2.6.28-rc
Date: Thu, 06 Nov 2008 15:50:55 -0800 (PST)
Message-ID: <20081106.155055.158286541.davem@davemloft.net>
References: <20081106065003.GA19105@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751481AbYKFXu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 18:50:56 -0500
In-Reply-To: <20081106065003.GA19105@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 6 Nov 2008 01:50:03 -0500

> Mark McLoughlin (2):
>       virtio_net: don't set NETIF_F_FRAGLIST
>       tun: don't set NETIF_F_FRAGLIST

These patches aren't correct, the drivers do in fact handle fragment
lists properly as was discussed in the threads where these patches
were posted.

Please pull these changes out and resend your pull request, thanks Jeff!
