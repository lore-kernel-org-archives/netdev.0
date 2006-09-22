From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Thu, 21 Sep 2006 23:35:30 -0500
Message-ID: <45136812.5060203@lwfinger.net>
References: <20060906124447.642940bd@localhost.localdomain> <01cb01c6d542$88544620$5001010a@bluereef.local> <20060919133159.27165976@localhost.localdomain> <089101c6ddfd$20ba4320$0b00000a@bluereef.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:26851 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751605AbWIVEfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 00:35:45 -0400
To: Andrew Hall <andrew.hall@bluereefnetworks.com>
In-Reply-To: <089101c6ddfd$20ba4320$0b00000a@bluereef.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Hall wrote:
> Unfortunately I spoke too soon.. :-(
> 
> The driver no longer appears to fail under load but still fails randomly 
> with relatively light load:
> 

I don't know if this will help, but NETDEV watchdog timeouts in the bcm43xx driver were fixed by 
changing a netif_stop_queue call into a netif_tx_disable. Why wrapping the stop_queue inside 
netif_tx_lock_bh/netif_tx_unlock_bh pairs works is beyond me, but ...

Larry
