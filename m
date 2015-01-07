From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Wed, 7 Jan 2015 15:46:55 -0800
Message-ID: <CAOxq_8NN1xi7Y1kiN-un+usU0Nz_CX8bkvhM50VSTsFXNJnGaA@mail.gmail.com>
References: <1420587382-24612-1-git-send-email-ani@arista.com> <063D6719AE5E284EB5DD2968C1650D6D1CAC2762@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "corbet@lwn.net" <corbet@lwn.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"P@draigbrady.com" <P@draigbrady.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fruggeri@arista.com" <fruggeri@arista.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC2762@AcuExch.aculab.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 7, 2015 at 2:11 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Ani Sinha
>> Update documentation to reflect the fact that
>> /proc/sys/net/ipv4/route/max_size is no longer used for ipv4.
>>
>> Signed-off-by: Ani Sinha <ani@arista.com>
>> ---
>>  Documentation/networking/ip-sysctl.txt |    6 ++++--
>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 9bffdfc..2a28261 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -64,8 +64,10 @@ fwmark_reflect - BOOLEAN
>>       Default: 0
>>
>>  route/max_size - INTEGER
>> -     Maximum number of routes allowed in the kernel.  Increase
>> -     this when using large numbers of interfaces and/or routes.
>> +     Post linux kernel 3.6, this is deprecated for ipv4 as route cache is no
>> +     longer used. For ipv6, this is used to limit the maximum number of ipv6
>> +     routes allowed in the kernel.  Increase this when using large numbers of
>> +     interfaces and/or routes.
>
> Now imagine you are reading ip-sysctl.txt, the new text is all wrong.
> Something like:
>         Limit on the size of the ip route caches.
>         Ignored for ipv4 after kernel 3.6 because the ipv4 route cache was removed.
>         Increase this when using large numbers of interfaces and/or routes.
> would read better.

Ok please take a look at my patch v2.
