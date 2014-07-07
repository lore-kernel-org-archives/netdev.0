From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH] appletalk: Set skb with destructor
Date: Mon, 7 Jul 2014 13:02:48 +0300
Message-ID: <CANZNk81UtoCOANXnmUPLx3uCP37BH=Wb54YjD3UQ1BwNc1P2Vw@mail.gmail.com>
References: <20140705202821.GA25880@mwanda>
	<1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<CANZNk81v7YHKpzjZ65KHdUi1BgBiV_ibZO24b8uauuCVZeUv2A@mail.gmail.com>
	<1404723456.4501.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<1404725217.4501.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1404725217.4501.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-07 12:26 GMT+03:00 Eric Dumazet <eric.dumazet@gmail.com>:
> Reading again this code, I think all you need is to remove the 2 buggy
> lines.
>
> No need for setup destructors.

Reviewing the code again, i find you're right and adding a destructor
in that place is stupid, and just not setting skb->sk would make bug
disappear, assuming skb->sk is previously NULL.
And what about the second case, at ddp.c near line 1650? Is destructor
needed here?

-- 
Andrey Utkin
