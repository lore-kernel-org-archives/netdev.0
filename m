From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN
Date: Tue, 15 Dec 2009 16:28:31 +0900
Message-ID: <aec7e5c30912142328l77efbb22rc5bdc45dc897f781@mail.gmail.com>
References: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
	 <20091214.215753.147971281.davem@davemloft.net>
	 <aec7e5c30912142313p111565d4mc0014c581cd431d4@mail.gmail.com>
	 <20091214.231534.225225771.davem@davemloft.net>
	 <aec7e5c30912142322w21fb4a1bved19f7344f1cf1a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <aec7e5c30912142322w21fb4a1bved19f7344f1cf1a5@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 4:22 PM, Magnus Damm <magnus.damm@gmail.com> wrote:
> On Tue, Dec 15, 2009 at 4:15 PM, David Miller <davem@davemloft.net> wrote:
>> NET_IP_ALIGN is never != 2 on SUPERH
>>
>> SH_ETH depends on SUPERH
>>
>> It's a fantasy ifdef, of sorts. :-)
>
> Sure, but _maybe_ someone will put the sh_eth hardware block together
> with MIPS or ARM in the future. I guess it makes more sense to just
> use the NET_IP_ALIGN value blindly and not care so much about what is
> known working and what is not...?

Well, it's in the sh7724 specific portion of the code and I guess
that's SUPERH. =)

/ magnus
