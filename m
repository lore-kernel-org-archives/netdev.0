From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/5] net: dsa: add missing kfree on remove
Date: Sun, 4 Oct 2015 00:54:33 +0300
Message-ID: <56104E99.5020105@cogentembedded.com>
References: <560FE575.7000003@baylibre.com>
 <560FE731.6050600@cogentembedded.com> <560FF239.2060903@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35617 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbbJCVyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 17:54:36 -0400
Received: by lackq9 with SMTP id kq9so363101lac.2
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 14:54:34 -0700 (PDT)
In-Reply-To: <560FF239.2060903@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/3/2015 6:20 PM, Neil Armstrong wrote:

>> On 10/3/2015 5:25 PM, Neil Armstrong wrote:
>>
>>> To prevent memory leakage on unbinding, add missing kfree calls.
>>>
>>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>>> ---
>>>    net/dsa/dsa.c | 5 ++++-
>>>    1 file changed, 4 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>>> index c59fa5d..12cec40 100644
>>> --- a/net/dsa/dsa.c
>>> +++ b/net/dsa/dsa.c
>>> @@ -914,8 +914,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
>>>        for (i = 0; i < dst->pd->nr_chips; i++) {
>>>            struct dsa_switch *ds = dst->ds[i];
>>>
>>> -        if (ds != NULL)
>>> +        if (ds != NULL) {
>>
>>     Didn;t scripts/checkpatch.pl complain here? just if (ds) is preferred in the networking code.
>>
>> MBR, Sergei
>>
> Yes,
>
> But I considered the cosmetic changes are not the subject of this serie.

    Formally, all the patches should be checkpatch-clean...

> Neil

MBR, Sergei
