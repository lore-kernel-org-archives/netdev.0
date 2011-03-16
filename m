From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: enable netpoll without checking
 link status
Date: Wed, 16 Mar 2011 12:58:37 -0700 (PDT)
Message-ID: <20110316.125837.229748529.davem@davemloft.net>
References: <1300140321-12056-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753528Ab1CPT6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 15:58:00 -0400
In-Reply-To: <1300140321-12056-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Mon, 14 Mar 2011 18:05:21 -0400

> Only slaves that are up should transmit netpoll frames, so there is no
> need to check to see if a slave is up before enabling netpoll on it.
> This resolves a reported failure on active-backup bonds where a slave
> interface is down when netpoll was enabled.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Tested-by: WANG Cong <amwang@redhat.com>

Applied, thanks Andy.
