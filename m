From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Thu, 21 Mar 2013 13:56:41 -0400 (EDT)
Message-ID: <20130321.135641.1239176040549971599.davem@davemloft.net>
References: <514AA946.6020603@redhat.com>
	<CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
	<20130321.134914.231367983776200354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3CUR4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:56:43 -0400
In-Reply-To: <20130321.134914.231367983776200354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 21 Mar 2013 13:49:14 -0400 (EDT)

> From: Willem de Bruijn <willemb@google.com>
> Date: Thu, 21 Mar 2013 13:27:51 -0400
> 
>> @@ -182,7 +182,13 @@ static char *sock_fanout_open_ring(int fd)
>>                 .tp_frame_nr   = RING_NUM_FRAMES,
>>         };
>>         char *ring;
>> +       int val = TPACKET_V2;
>> 
>> +       if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, (void *) &val,
> 
> This whole patch is whitespace damaged.

I hand applied this patch and it makes the test pass on sparc64.

Please submit this formally, thanks.
