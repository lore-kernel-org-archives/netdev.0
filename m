From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v3] can: Fix kernel panic at security_sock_rcv_skb
Date: Fri, 10 Feb 2017 09:28:57 +0100
Message-ID: <9f8cc561-e1e6-c2f6-2bcc-3fe0282ca05c@hartkopp.net>
References: <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
 <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170129.183406.1410276231781823069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170129.183406.1410276231781823069.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave, Greg,

On 01/30/2017 12:34 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Jan 2017 08:11:44 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Zhang Yanmin reported crashes [1] and provided a patch adding a
>> synchronize_rcu() call in can_rx_unregister()
>>
>> The main problem seems that the sockets themselves are not RCU
>> protected.
>>
>> If CAN uses RCU for delivery, then sockets should be freed only after
>> one RCU grace period.
>>
>> Recent kernels could use sock_set_flag(sk, SOCK_RCU_FREE), but let's
>> ease stable backports with the following fix instead.
>  ...
>> Reported-by: Zhang Yanmin <yanmin.zhang@intel.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Applied and queued up for -stable, thanks Eric.
>

can you please check whether this upstream commit

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f1712c73714088a7252d276a57126d56c7d37e64

really was queued up for -stable?

This commit

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a06393ed03167771246c4c43192d9c264bc48412

was posted later and already got into the 4.4 and 4.9 stable trees.

Best regards,
Oliver
