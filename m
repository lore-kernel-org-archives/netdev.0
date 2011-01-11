From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] net: Allow allocating different number RX and TX mqs
Date: Mon, 10 Jan 2011 16:28:36 -0800
Message-ID: <AANLkTik=Ko9KCi9pVm_d+yaDtM-LkVC1bazSPFfV57b1@mail.gmail.com>
References: <alpine.DEB.2.00.1101092123340.3137@pokey.mtv.corp.google.com>
	<20110110.160642.146350621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:17288 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184Ab1AKA2j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:28:39 -0500
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p0B0ScAY001755
	for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 16:28:38 -0800
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz24.hot.corp.google.com with ESMTP id p0B0SaTl007970
	for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 16:28:37 -0800
Received: by pwj10 with SMTP id 10so3955544pwj.2
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 16:28:36 -0800 (PST)
In-Reply-To: <20110110.160642.146350621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 4:06 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 9 Jan 2011 21:36:25 -0800 (PST)
>
>> Add functions so that a different number of TX and RX queues can be
>> allocated in a netdevice. =A0Second patch modifies mlx4 driver to ca=
ll
>> this function which is an example of a driver that allocates differe=
nt
>> numbers for TX and RX queues.
>
> Both applied, thanks Tom.
>

Thanks.  By the way I didn't see a maintainer for the mlx drivers in
the MAINTAINERS files.  Who maintains these?
