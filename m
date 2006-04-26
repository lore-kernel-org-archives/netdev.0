From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] sky2: reschedule if irq still pending
Date: Wed, 26 Apr 2006 06:20:10 -0400
Message-ID: <444F495A.1020008@pobox.com>
References: <20060425175849.372221000@localhost.localdomain> <20060425175951.185516000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41703 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932073AbWDZKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 06:20:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060425175951.185516000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This is a workaround for the case edge-triggered irq's. Several users
> seem to have broken configurations sharing edge-triggered irq's. To avoid
> losing IRQ's, reshedule if more work arrives.
> 
> The changes to netdevice.h are to extract the part that puts device
> back in list into separate inline.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied 1-5 to #upstream-fixes


