From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 1/5] net: dsa: add missing kfree on remove
Date: Tue, 6 Oct 2015 08:25:33 +0100
Message-ID: <5613776D.8060103@baylibre.com>
References: <560FE575.7000003@baylibre.com>
 <560FE731.6050600@cogentembedded.com> <560FF239.2060903@baylibre.com>
 <56104E99.5020105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56104E99.5020105@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/2015 10:54 PM, Sergei Shtylyov wrote:
> On 10/3/2015 6:20 PM, Neil Armstrong wrote:
> 
>>> On 10/3/2015 5:25 PM, Neil Armstrong wrote:
>>>
>>>> To prevent memory leakage on unbinding, add missing kfree calls.
>>>>
>>>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>>>> ---
>>>>    net/dsa/dsa.c | 5 ++++-
>>>>    1 file changed, 4 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>>>> index c59fa5d..12cec40 100644
>>>> --- a/net/dsa/dsa.c
>>>> +++ b/net/dsa/dsa.c
>>>> @@ -914,8 +914,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
>>>>        for (i = 0; i < dst->pd->nr_chips; i++) {
>>>>            struct dsa_switch *ds = dst->ds[i];
>>>>
>>>> -        if (ds != NULL)
>>>> +        if (ds != NULL) {
>>>
>>>     Didn;t scripts/checkpatch.pl complain here? just if (ds) is preferred in the networking code.
>>>
>>> MBR, Sergei
>>>
>> Yes,
>>
>> But I considered the cosmetic changes are not the subject of this serie.
> 
>    Formally, all the patches should be checkpatch-clean...
> 
>> Neil
> 
> MBR, Sergei
> 
Sure,

How should I handle this case ?
A separate patch with the cosmetic change before the kfree addition ?

Neil
