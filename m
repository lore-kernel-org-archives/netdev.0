From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Au1x00: fix crash when trying register_netdev()
Date: Sun, 22 Nov 2009 20:41:16 -0800 (PST)
Message-ID: <20091122.204116.115920809.davem@davemloft.net>
References: <1258772855-9141-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alohre@gmail.com
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756338AbZKWEk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 23:40:59 -0500
In-Reply-To: <1258772855-9141-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Sat, 21 Nov 2009 06:07:35 +0300

> Andreas Lohre reported that the driver crashes when trying
> to register_netdev(), he sugessted to move dev->netdev_ops initialization
> before calling register_netdev(), it worked for him.
> 
> Reported-by: Andreas Lohre <alohre@gmail.com>
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.

> David, please send it to stable@ for 2.6.31

Will do, thanks.
