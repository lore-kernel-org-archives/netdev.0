From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: Add comments to the registers definition
Date: Tue, 11 Apr 2017 22:18:36 -0400 (EDT)
Message-ID: <20170411.221836.113758478587841074.davem@davemloft.net>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
        <20170410135251.GC19820@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@wetterwald.eu, davem@davemloft.org,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751992AbdDLCSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:18:38 -0400
In-Reply-To: <20170410135251.GC19820@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 10 Apr 2017 15:52:51 +0200

> Hi Martin
> 
>> @@ -2032,7 +2032,7 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
>>  	skb_push(skb, 4);
>>  	tx_cmd_b = (u32)(skb->len - 4);
>>  	if (csum)
>> -		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
>> +		tx_cmd_b |= TX_CMD_B_CSUM_EN;
> 
> This changed seems a step backwards, ENABLE is much more readable than EN.
> 
>>  
>> -#define TX_CMD_B_CSUM_ENABLE		(0x00004000)
>> -#define TX_CMD_B_ADD_CRC_DISABLE_	(0x00002000)
>> -#define TX_CMD_B_DISABLE_PADDING_	(0x00001000)
>> -#define TX_CMD_B_PKT_BYTE_LENGTH_	(0x000007FF)
>> +#define TX_CMD_B_CSUM_EN	(0x00004000)	/* TX Checksum Enable */
> 
> And there is space for ABLE here.

I completely agree, Martin please don't ENABLE to EN.
