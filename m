From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: ptp: Add CONFIG mode support
Date: Sun, 6 Dec 2015 22:19:56 +0300
Message-ID: <56648A5C.40702@cogentembedded.com>
References: <1448989479-11594-1-git-send-email-ykaneko0929@gmail.com>
 <5660AF89.1010008@cogentembedded.com>
 <CAH1o70+n7m+4rmVvTbi9VNBknzV9s_04dsADhJ4RSkuC07ti7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAH1o70+n7m+4rmVvTbi9VNBknzV9s_04dsADhJ4RSkuC07ti7A@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/05/2015 01:01 PM, Yoshihiro Kaneko wrote:

> Thanks for your review.

    From now on, it'll be my duty. :-)

> 2015-12-04 6:09 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
>> Hello.
>>
>> On 12/01/2015 08:04 PM, Yoshihiro Kaneko wrote:
>>
>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch makes PTP support active in CONFIG mode on R-Car Gen3.
>>>
>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>> ---
>>>
>>> This patch is based on the master branch of David Miller's next networking
>>> tree.
>>>
>>>    drivers/net/ethernet/renesas/ravb.h      |  1 +
>>>    drivers/net/ethernet/renesas/ravb_main.c | 33
>>> +++++++++++++++++++++++++++-----
>>>    2 files changed, 29 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/renesas/ravb.h
>>> b/drivers/net/ethernet/renesas/ravb.h
>>> index f9dee74..9fbe92a 100644
>>> --- a/drivers/net/ethernet/renesas/ravb.h
>>> +++ b/drivers/net/ethernet/renesas/ravb.h
[...]

>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>> index 990dc55..293046d 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>> @@ -1855,6 +1870,10 @@ out_napi_del:
>>>    out_dma_free:
>>>          dma_free_coherent(ndev->dev.parent, priv->desc_bat_size,
>>> priv->desc_bat,
>>>                            priv->desc_bat_dma);
>>> +
>>> +       /* Stop PTP Clock driver */
>>> +       if (chip_id != RCAR_GEN2)
>>> +               ravb_ptp_stop(ndev);
>>
>>
>>     This is clearly misplaced.
>
> It's my fault.

    Should we expect a new patch fixing this issue?

[...]

> Regards,
> Kaneko

MBR, Sergei

