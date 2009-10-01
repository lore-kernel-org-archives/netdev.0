From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Remove prev_vlan_tag from struct tx_ring_info
Date: Thu, 01 Oct 2009 14:38:59 -0700 (PDT)
Message-ID: <20091001.143859.53379358.davem@davemloft.net>
References: <4AC36638.8070304@gmail.com>
	<20090930172643.GA14439@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752943AbZJAVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:38:40 -0400
In-Reply-To: <20090930172643.GA14439@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 30 Sep 2009 10:26:43 -0700

> On Wed, Sep 30, 2009 at 07:07:52AM -0700, Eric Dumazet wrote:
>> prev_vlan_tag field is not used.
>> 
>> Patch saves 512*8 bytes per tx queue ring on 64bit arches.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Looks good to me.
> 
> Acked-by: Matthew Carlson <mcarlson@broadcom.com>

Applied, thanks.

Eric, I had to apply this by hand because:

>> @@ -2412,7 +2412,6 @@ struct ring_info {
>>  
>>  struct tx_ring_info {
>>  	struct sk_buff                  *skb;
>> -	u32                             prev_vlan_tag;
>>  };

Your email client changed tabs into spaces.
