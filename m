From: Bas Peters <baspeters93@gmail.com>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch errors
Date: Sat, 7 Feb 2015 19:02:36 +0100
Message-ID: <CAOgR63e6kN74=9ORw4bWxN2zUar8hphkLExwP2wawuLWZR+Kkw@mail.gmail.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	<1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	<54D650BF.5000400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "isdn@linux-pingi.de" <isdn@linux-pingi.de>, julia.lawall@lip6.fr,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D650BF.5000400@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, will take that into account in future patches.

With kind regards,

Bas

2015-02-07 18:51 GMT+01:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 02/07/2015 08:06 PM, Bas Peters wrote:
>
>> This patch fixes the following checkpatch errors:
>>         1. trailing statement
>>         1. assignment of variable in if condition
>>         1. incorrectly placed brace after function definition
>
>
>> Signed-off-by: Bas Peters <baspeters93@gmail.com>
>> ---
>>   drivers/isdn/act2000/capi.c | 9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>
>
>> diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
>> index 3f66ca2..5d677e6 100644
>> --- a/drivers/isdn/act2000/capi.c
>> +++ b/drivers/isdn/act2000/capi.c
>> @@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr
>> *hdr)
>>                         m->hdr.cmd.cmd = c;                     \
>>                         m->hdr.cmd.subcmd = s;                  \
>>                         m->hdr.msgnum = actcapi_nextsmsg(card); \
>> -               } else m = NULL;                                \
>> +               } else
>> +                       m = NULL;                               \
>
>
>    Documentation/CodingStyle has an extra rule for such case: *else* branch
> should also have {} since *if* branch has {}.
>
> [...]
>
> WNR, Sergei
>
