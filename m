From: Jon Christopherson <jon@jons.org>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
Date: Mon, 17 Aug 2015 19:05:41 -0500
Message-ID: <55D276D5.3@jons.org>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
 <20150812.144040.1151964094247340464.davem@davemloft.net>
 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
 <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
 <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <963062024.20150817110956@eikelenboom.it>
 <1439818633.7258.16.camel@edumazet-glaptop2.roam.corp.google.com>
 <196897465.20150817154802@eikelenboom.it> <55D1E97B.6090309@jons.org>
 <1439821307.7258.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <373726164.20150817162534@eikelenboom.it>
 <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	david.vrabel@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2015 12:18 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

<snip>

>
> Then can you try following fix as well ?
>
> Thanks !
>
> [PATCH] timer: fix a race in __mod_timer()
>

<snip>

I have been running the latest code from git with the 2 patches in this 
thread applied. No issues so far.

-Jon
