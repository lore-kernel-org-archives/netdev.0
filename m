From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Thu, 21 Mar 2013 14:01:46 -0400
Message-ID: <CA+FuTSewLdQZbWPLrdbtG2xtaWSdrPDO3yz6boXqgStYhh3fcg@mail.gmail.com>
References: <514AA946.6020603@redhat.com> <CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
 <20130321.134914.231367983776200354.davem@davemloft.net> <20130321.135641.1239176040549971599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:44371 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab3CUSCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 14:02:17 -0400
Received: by mail-wg0-f46.google.com with SMTP id fg15so2432121wgb.13
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 11:02:16 -0700 (PDT)
In-Reply-To: <20130321.135641.1239176040549971599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 1:56 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 21 Mar 2013 13:49:14 -0400 (EDT)
>
>> From: Willem de Bruijn <willemb@google.com>
>> Date: Thu, 21 Mar 2013 13:27:51 -0400
>>
>>> @@ -182,7 +182,13 @@ static char *sock_fanout_open_ring(int fd)
>>>                 .tp_frame_nr   = RING_NUM_FRAMES,
>>>         };
>>>         char *ring;
>>> +       int val = TPACKET_V2;
>>>
>>> +       if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, (void *) &val,
>>
>> This whole patch is whitespace damaged.

Sorry. I did not know that that happened with cut and paste into gmail.

> I hand applied this patch and it makes the test pass on sparc64.

Great. Thanks for testing.

> Please submit this formally, thanks.

Will follow up right away.
