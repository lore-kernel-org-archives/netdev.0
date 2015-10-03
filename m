From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 1/5] net: dsa: add missing kfree on remove
Date: Sat, 3 Oct 2015 17:20:25 +0200
Message-ID: <560FF239.2060903@baylibre.com>
References: <560FE575.7000003@baylibre.com>
 <560FE731.6050600@cogentembedded.com>
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
In-Reply-To: <560FE731.6050600@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/2015 04:33 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 10/3/2015 5:25 PM, Neil Armstrong wrote:
> 
>> To prevent memory leakage on unbinding, add missing kfree calls.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>>   net/dsa/dsa.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>> index c59fa5d..12cec40 100644
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -914,8 +914,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
>>       for (i = 0; i < dst->pd->nr_chips; i++) {
>>           struct dsa_switch *ds = dst->ds[i];
>>
>> -        if (ds != NULL)
>> +        if (ds != NULL) {
> 
>    Didn;t scripts/checkpatch.pl complain here? just if (ds) is preferred in the networking code.
> 
> MBR, Sergei
> 
Yes,

But I considered the cosmetic changes are not the subject of this serie.

Neil
