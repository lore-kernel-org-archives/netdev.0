From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, WTF] atm: move all compat_ioctl handling to atm/ioctl.c
Date: Tue, 10 Nov 2009 20:41:18 -0800 (PST)
Message-ID: <20091110.204118.12070030.davem@davemloft.net>
References: <200911061500.01651.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756755AbZKKEkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 23:40:52 -0500
In-Reply-To: <200911061500.01651.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I agree that this should be done in one place, rather than split up
like it is now.  Can you please respin your changes against
net-next-2.6 since the code you are changing here is no longer in
fs/compat_ioctl.c due to your other patch set?

Thanks.
