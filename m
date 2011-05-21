From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Sat, 21 May 2011 23:42:49 +0800
Message-ID: <BANLkTikrCBcCm4qksA-8u0n+vTwiuc=WuA@mail.gmail.com>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
 <124481299095426@web67.yandex.ru> <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>
 <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
 <586191301580222@web107.yandex.ru> <1301582872.3169.44.camel@edumazet-laptop> <4D9B01DF.2050206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Oleg A. Arkhangelsky" <sysoleg@yandex.ru>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D9B01DF.2050206@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 5, 2011 at 7:49 PM, Patrick McHardy <kaber@trash.net> wrote:
>
> I think what's happening is that the conntrack entry is destroyed
> and the NAT ct_extend destructor invoked, which removes the nat
> extension from the RCU protected bysource hash, after which the
> entire extension area is freed. Another CPU might still find the
> old NAT entry with undefined contents in the hash though, so I
> think using RCU to free the extension area is correct.
>

What is the conclusion? Is my patch acceptable? Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
