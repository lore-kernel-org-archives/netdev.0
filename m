From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gainfar.c : skb_over_panic
Date: Wed, 23 Jun 2010 11:27:26 -0700 (PDT)
Message-ID: <20100623.112726.193704241.davem@davemloft.net>
References: <4C1F2D39.9050804@extricom.com>
	<20100621.134733.115953029.davem@davemloft.net>
	<4C2249E6.4030202@extricom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: liberty@extricom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752036Ab0FWS1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 14:27:14 -0400
In-Reply-To: <4C2249E6.4030202@extricom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Liberty <liberty@extricom.com>
Date: Wed, 23 Jun 2010 20:52:38 +0300

> David Miller wrote:
>> At this stage in the code we know exactly what modifications, if any,
>> we've made to the SKB state.  Therefore it makes sense to only fix
>> up the tiny amount of changes we've made instead of doing a complete
>> skb_recycle_call() which seems entirely excessive in this situation.
>>
>>   
> Agreed.
> 
> Attached is the corrected patch for the gianfar.c

Can you formally submit this with a proper commit message and
"Signed-off-by: " tag as per linux/Documentation/SubmittingPatches?

THanks.
