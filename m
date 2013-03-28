From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH 1/6] net-next: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Fri, 29 Mar 2013 00:08:26 +0800
Message-ID: <CAA7+ByVp4K__=mESAu4jEy=t4TJD+rV0KOA2ZhHSinm1fvedzg@mail.gmail.com>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
	<20130328143216.GC23043@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130328143216.GC23043@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, Thomas. But I didn't change any formatting. Just do the
substitution in place.
Should I re-format and re-send the patch?

On Thu, Mar 28, 2013 at 10:32 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 03/28/13 at 12:47am, Hong Zhiguo wrote:
>> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
>> index 505b30a..467fb92 100644
>> --- a/net/ipv4/udp_diag.c
>> +++ b/net/ipv4/udp_diag.c
>> @@ -64,9 +64,9 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>>               goto out;
>>
>>       err = -ENOMEM;
>> -     rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
>> -                                  sizeof(struct inet_diag_meminfo) +
>> -                                  64)), GFP_KERNEL);
>> +     rep = nlmsg_new(sizeof(struct inet_diag_msg) +
>> +                                  sizeof(struct inet_diag_meminfo) + 64,
>> +                                  GFP_KERNEL);
>
> This is formatted incorrectly, otherwise the patch looks good.



--
best regards
Hong Zhiguo
