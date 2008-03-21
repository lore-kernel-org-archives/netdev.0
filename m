From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][DLCI]: Fix tiny race between module unload and
 sock_ioctl.
Date: Fri, 21 Mar 2008 15:59:12 -0700 (PDT)
Message-ID: <20080321.155912.75382919.davem@davemloft.net>
References: <47E3DBB1.4090706@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike.mclagan@linux.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764727AbYCUW66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:58:58 -0400
In-Reply-To: <47E3DBB1.4090706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 21 Mar 2008 19:00:49 +0300

> This is a narrow pedantry :) but the dlci_ioctl_hook check and call
> should not be parted with the mutex lock.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
