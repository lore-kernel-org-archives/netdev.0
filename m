From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 11:18:30 -0800
Message-ID: <4CE57C06.4080105@gmail.com>
References: <1290093135.2781.167.camel@edumazet-laptop>	<4CE561A2.2020600@gmail.com>	<1290102497.2781.242.camel@edumazet-laptop> <20101118.095046.28818361.davem@davemloft.net> <4CE56CC4.4020107@gmail.com> <4CE56E89.4000902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, horms@verge.net.au,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4CE56E89.4000902@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/18/2010 10:20 AM, Patrick McHardy wrote:
> Am 18.11.2010 19:13, schrieb Justin P. Mattock:
>> On 11/18/2010 09:50 AM, David Miller wrote:
>>> From: Eric Dumazet<eric.dumazet@gmail.com>
>>> Date: Thu, 18 Nov 2010 18:48:17 +0100
>>>
>>>> Let me guess...
>>>>
>>>> net/netfilter/nf_conntrack_core is compiled as a module, and ip_vs
>>>> statically (in vmlinux) ?
>>>>
>>>> CONFIG_NF_CONNTRACK=m
>>>> CONFIG_IP_VS=y
>>>>
>>>> We probably need some Kconfig magic ;)
>>>
>
> Please try whether this patch fixes the problem.
>
> netfilter: fix IP_VS dependencies
>
> When NF_CONNTRACK is enabled, IP_VS uses conntrack symbols.
> Therefore IP_VS can't be linked statically when conntrack
> is built modular.
>
> Reported-by: Justin P. Mattock<justinmattock@gmail.com>
> Signed-off-by: Patrick McHardy<kaber@trash.net>
>
>


alright!! doing the above change
CONFIG_NF_CONNTRACK=y gets a clean build.. as well as reverting 
everything and using your patch..

Thanks for the fix..

Justin P. Mattock
