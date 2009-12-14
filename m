From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Mon, 14 Dec 2009 14:20:02 +0100
Message-ID: <4B263B82.4@trash.net>
References: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com> <alpine.LSU.2.01.0912102301380.5189@obet.zrqbmnf.qr> <20091210.140843.142337259.davem@davemloft.net> <alpine.LSU.2.01.0912110043320.11964@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chavey@google.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	eric.dumazet@gmail.com, akpm@google.com
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.0912110043320.11964@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Donnerstag 2009-12-10 23:08, David Miller wrote:
>>> On Donnerstag 2009-12-10 22:44, chavey@google.com wrote:
>>>
>>>> Fix compiler warning "discards qualifiers from pointer target type",
>>>> by allowing explicit discard of const qualifier thru type casting.
>>>> The const_cast() macro is taken from a patch from Kaveh R. Ghazi
>>> Uhm, I am not getting any warning on xt_time with either gcc-4.4.1
>>> or gcc-4.5_20091126, so what case are we actually trying to fix?
>> I get this warning with gcc-4.3.x all the time.
> 
> Seems they fixed it in gcc-4.3 too?
> 
> 00:41 borg:~/code/linux > make net/netfilter/xt_time.o -j8 CC=gcc-4.3

Yes, I haven't seen it for a long time either, currently using
gcc version 4.3.4 (Debian 4.3.4-6) and gcc version 4.4.1
(Debian 4.4.1-3)

I don't think we need to bother with this.
