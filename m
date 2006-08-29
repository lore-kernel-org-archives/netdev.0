From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 7/9] sky2: power down PHY when not up
Date: Tue, 29 Aug 2006 17:04:59 -0400
Message-ID: <44F4ABFB.1020105@pobox.com>
References: <20060828170044.136391412@localhost.localdomain> <20060828170219.598956798@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35469 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965324AbWH2VFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 17:05:01 -0400
To: shemminger@osdl.org
In-Reply-To: <20060828170219.598956798@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org wrote:
> To save power, don't enable power to the PHY until device is brought up.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Strongly agree, and ACK, but note that users have complained in the past 
when they could not configure their MAC when the interface was down. 
Users want to eliminate the

	ifconfig ethX up
	ethtool ...

race window.

	Jeff



