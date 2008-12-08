From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Kill directly reference of netdev->priv
Date: Mon, 08 Dec 2008 12:27:42 -0800 (PST)
Message-ID: <20081208.122742.46904963.davem@davemloft.net>
References: <20081208145333.GB6830@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbYLHU1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 15:27:41 -0500
In-Reply-To: <20081208145333.GB6830@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jianjun, please...

In the net-next-2.6 tree every single netdev_priv() conversion
has been done already.  netdev->priv doesn't even exist any
more, so you are duplicating a lot of work needlessly.
