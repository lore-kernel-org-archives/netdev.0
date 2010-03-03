From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bluetooth: Use single_open() for inquiry cache within
 debugfs
Date: Wed, 03 Mar 2010 01:07:09 -0800 (PST)
Message-ID: <20100303.010709.209984281.davem@davemloft.net>
References: <1267580903-30946-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753871Ab0CCJGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 04:06:50 -0500
In-Reply-To: <1267580903-30946-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue,  2 Mar 2010 17:48:23 -0800

> The inquiry cache information in debugfs should be using seq_file support
> and not allocating memory on the stack for the string. Since the usage of
> these information is really seldom, using single_open() for it is good
> enough.
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Applied, thanks Marcel.

I guess we'll never figure out why my patch didn't work ;-)
