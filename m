From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 5/7] x25: remove the BKL
Date: Thu, 3 Mar 2011 18:38:22 +1100
Message-ID: <AANLkTinfM=OyMwHEuMejNtcXTUSWP=j_9oYXSU0gx=8Q@mail.gmail.com>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de>
	<1299021191-17961-6-git-send-email-arnd@arndb.de>
	<20110301.151622.200374696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, linux-kernel@vger.kernel.org,
	linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110301.151622.200374696.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good, put 8gig through it over the past few days and system stabl=
e.

Tested-by: Andrew Hendry <andrew.hendry@gmail.com>

On Wed, Mar 2, 2011 at 10:16 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, =A02 Mar 2011 00:13:09 +0100
>
>> This replaces all instances of lock_kernel in x25
>> with lock_sock, taking care to release the socket
>> lock around sleeping functions (sock_alloc_send_skb
>> and skb_recv_datagram). It is not clear whether
>> this is a correct solution, but it seem to be what
>> other protocols do in the same situation.
>>
>> Includes a fix suggested by Eric Dumazet.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
