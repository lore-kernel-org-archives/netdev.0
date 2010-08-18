From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ether1: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 13:10:43 -0700 (PDT)
Message-ID: <20100818.131043.226780154.davem@davemloft.net>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
	<1282115064-3701-1-git-send-email-tklauser@distanz.ch>
	<20100818083304.2ef2eea4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, error27@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754038Ab0HRUKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 16:10:24 -0400
In-Reply-To: <20100818083304.2ef2eea4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Aug 2010 08:33:04 -0700

> On Wed, 18 Aug 2010 09:04:24 +0200
> Tobias Klauser <tklauser@distanz.ch> wrote:
> 
>>  
>> -	memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));
>> +	memset(&dev->stats, 0, sizeof(struct net_device_stats));
> 
> This is incorrect, just remove the memset.  The stats are initialized
> when device is created.  The Linux device driver convention is to
> keep stats when device is set down and brought back up; that is what
> the majority of other drivers do.

Yep, both the ether1 and ether3 patch have this problem.  Looks
like we'll see v4 coming some :-)
