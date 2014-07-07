From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH] appletalk: Set skb with destructor
Date: Mon, 7 Jul 2014 11:03:41 +0300
Message-ID: <CANZNk81v7YHKpzjZ65KHdUi1BgBiV_ibZO24b8uauuCVZeUv2A@mail.gmail.com>
References: <20140705202821.GA25880@mwanda>
	<1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-07 0:42 GMT+03:00 Eric Dumazet <eric.dumazet@gmail.com>:
>>       /* Queue packet (standard) */
>> +     sock_hold(sock);
>> +     skb->destructor = atalk_skb_destructor;
>>       skb->sk = sock;
>
> This part is not needed : sock_queue_rcv_skb() already does the right
> thing : It calls skb_set_owner_r(skb, sk);
>
> You should therefore remove the "skb->sk = sock;" line

If it is so, i think this should be as another patch with its own reasoning.

-- 
Andrey Utkin
