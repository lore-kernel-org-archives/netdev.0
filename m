From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH v2] sh_eth: Fix skb alloc size and alignment adjust rule.
Date: Thu, 27 Nov 2014 20:26:39 +0900
Message-ID: <CAH1o70+iTTPDebguJMg_gLC=zJgPHxaYU9tSta1rX=VkX+9XHw@mail.gmail.com>
References: <1416479721-23089-1-git-send-email-ykaneko0929@gmail.com>
	<20141121.150544.2240809721107766779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20141121.150544.2240809721107766779.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I'm very sorry for the late response.

2014-11-22 5:05 GMT+09:00 David Miller <davem@davemloft.net>:
> From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Date: Thu, 20 Nov 2014 19:35:21 +0900
>
>> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>>
>> In the current driver, allocation size of skb does not care the alig=
nment
>> adjust after allocation.
>> And also, in the current implementation, buffer alignment method by
>> sh_eth_set_receive_align function has a bug that this function displ=
ace
>> buffer start address forcedly when the alignment is corrected.
>> In the result, tail of the skb will exceed allocated area and kernel=
 panic
>> will be occurred.
>> This patch fix this issue.
>>
>> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>
>> The previous version of this patch was a part of the patch series as=
 follows:
>> [PATCH 2/3] sh_eth: Fix skb alloc size and alignment adjust rule.
>>
>> This series is based on net tree.
>>
>> v2 [Yoshihiro Kaneko]
>> * Update as suggested by Sergei Shtylyov
>>   - Fixed the coding style
>>   - Corrected the comment
>>   - Removed {SH2_SH3|SH4}_SKB_RX_ALIGN
>
> Please compile test your changes on 64-bit platforms:
>
> drivers/net/ethernet/renesas/sh_eth.c: In function =E2=80=98sh_eth_se=
t_receive_align=E2=80=99:
> drivers/net/ethernet/renesas/sh_eth.c:922:16: warning: cast from poin=
ter to integer of different size [-Wpointer-to-int-cast]

I have never seen that warning message because I had done compile test
for ARM platform.
I saw the warning after I do compile test for x86_64.
I'll post the new version of this patch.

Thanks,
Kaneko
