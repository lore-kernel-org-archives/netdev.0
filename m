From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH v3] net: bcmgenet: fix throughtput regression
Date: Mon, 2 Mar 2015 12:49:22 -0800
Message-ID: <CAGXr9JGQHCKav-Veo7zv2Vw=K-Zpupz7JEXCPPikU-Fqws5m4g@mail.gmail.com>
References: <1425091706-5811-1-git-send-email-jaedon.shin@gmail.com>
	<20150301.003007.247806713909808067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jaedon Shin <jaedon.shin@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:42873 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbbCBUtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:49:23 -0500
Received: by mail-qg0-f42.google.com with SMTP id z60so8643961qgd.1
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 12:49:22 -0800 (PST)
In-Reply-To: <20150301.003007.247806713909808067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When will this be available in net-next?

On Sat, Feb 28, 2015 at 9:30 PM, David Miller <davem@davemloft.net> wrote:
> From: Jaedon Shin <jaedon.shin@gmail.com>
> Date: Sat, 28 Feb 2015 11:48:26 +0900
>
>> This patch adds bcmgenet_tx_poll for the tx_rings. This can reduce the
>> interrupt load and send xmit in network stack on time. This also
>> separated for the completion of tx_ring16 from bcmgenet_poll.
>>
>> The bcmgenet_tx_reclaim of tx_ring[{0,1,2,3}] operative by an interrupt
>> is to be not more than a certain number TxBDs. It is caused by too
>> slowly reclaiming the transmitted skb. Therefore, performance
>> degradation of xmit after 605ad7f ("tcp: refine TSO autosizing").
>>
>> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Applied.
