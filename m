From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 9 Nov 2009 16:44:05 +0800
Message-ID: <412e6f7f0911090044v33c331edg6096c0f9b9db4143@mail.gmail.com>
References: <4AF7C1FD.8000302@gmail.com>
	 <20091108.232647.47855733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f195.google.com ([209.85.216.195]:61666 "EHLO
	mail-px0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbZKIIoA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 03:44:00 -0500
Received: by pxi33 with SMTP id 33so62145pxi.4
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 00:44:05 -0800 (PST)
In-Reply-To: <20091108.232647.47855733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 9, 2009 at 3:26 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Mon, 09 Nov 2009 15:17:17 +0800
>
>> check the return value of ndo_select_queue()
>>
>> Check the return value of ndo_select_queue(). If the value isn't sma=
ller
>> than the real_num_tx_queues, print a warning message, and reset it t=
o zero.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Make it a WARN() so that it ends up in kerneloops.org
>
Like this?
                        WARN(1, "%s selects TX queue %d, "
                             "but real number of TX queues is %d\n",
                             dev->name, queue_index, dev->real_num_tx_q=
ueues);

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
