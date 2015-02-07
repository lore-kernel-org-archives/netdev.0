From: Bas Peters <baspeters93@gmail.com>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch errors
Date: Sat, 7 Feb 2015 19:08:43 +0100
Message-ID: <CAOgR63dhGA4ULSACOSCBnU+uG_bMbegYY62o1etmRjo31BO9wQ@mail.gmail.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	<1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	<54D650BF.5000400@cogentembedded.com>
	<alpine.DEB.2.02.1502071902060.2050@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"isdn@linux-pingi.de" <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1502071902060.2050@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I must have missed something. I fixed it on my end. Do I now resend
the entire patchset or just this particular patch?

regards,

Bas

2015-02-07 19:02 GMT+01:00 Julia Lawall <julia.lawall@lip6.fr>:
> On Sat, 7 Feb 2015, Sergei Shtylyov wrote:
>
>> Hello.
>>
>> On 02/07/2015 08:06 PM, Bas Peters wrote:
>>
>> > This patch fixes the following checkpatch errors:
>> >     1. trailing statement
>> >     1. assignment of variable in if condition
>> >     1. incorrectly placed brace after function definition
>>
>> > Signed-off-by: Bas Peters <baspeters93@gmail.com>
>> > ---
>> >   drivers/isdn/act2000/capi.c | 9 ++++++---
>> >   1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> > diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
>> > index 3f66ca2..5d677e6 100644
>> > --- a/drivers/isdn/act2000/capi.c
>> > +++ b/drivers/isdn/act2000/capi.c
>> > @@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
>> >                     m->hdr.cmd.cmd = c;                     \
>> >                     m->hdr.cmd.subcmd = s;                  \
>> >                     m->hdr.msgnum = actcapi_nextsmsg(card); \
>> > -           } else m = NULL;                                \
>> > +           } else
>
> It looks like a \ was lost on this line.  It should have caused a compiler
> error.
>
> julia
>
>> > +                   m = NULL;                               \
>>
>>    Documentation/CodingStyle has an extra rule for such case: *else* branch
>> should also have {} since *if* branch has {}.
>>
>> [...]
>>
>> WNR, Sergei
>>
>>
