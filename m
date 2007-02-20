From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] r8169: RTNL and flush_scheduled_work deadlock
Date: Tue, 20 Feb 2007 11:18:23 -0500
Message-ID: <45DB1F4F.3010806@garzik.org>
References: <20070214132729.479793ac@freekitty> <20070215223721.GA19840@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44498 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965260AbXBTQSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:18:46 -0500
In-Reply-To: <20070215223721.GA19840@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> flush_scheduled_work() in net_device->close has a slight tendency
> to deadlock with tasks on the workqueue that hold RTNL.
> 
> rtl8169_close/down simply need the recovery tasks to not meddle
> with the hardware while the device is going down.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |   25 ++++++++++++++++++-------
>  1 files changed, 18 insertions(+), 7 deletions(-)

applied 1-4


