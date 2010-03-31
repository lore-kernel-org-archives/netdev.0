From: =?unknown-8bit?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 22:14:26 +0200
Message-ID: <20100331201426.GA3228@electric-eye.fr.zoreil.com>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
 <20100331111942.GB13963@hmsreliant.think-freely.org>
 <20100331121426.GB3294@swordfish.minsk.epam.com>
 <1270038569.2103.24.camel@edumazet-laptop>
 <20100331133533.GD13963@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100331133533.GD13963@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman <nhorman@redhat.com> :
[...]
> +1 I wouldn't be suprised if using something over the nominal 1522 byte frame
> length on r8169 caused tx errors.  The driver doesn't seem to support Jumbo
> frames, so my guess is you have to keep the packet size below 1522 bytes.

-1

The driver does not support Jumbo frames because the original 8169 will not
go much beyond 7200 (see r8169.c::SafeMtu and netdev circa 2004 december 7).

/me checks... Apparently it still works a bit.

Sergey, can you 'dmesg | grep XID' and send the output of a lspci as
well as the MTU used during the test ?

-- 
Ueimor
