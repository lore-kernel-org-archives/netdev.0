From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:06:51 -0400
Message-ID: <696ed966-991c-30f7-9a1c-d91a94c9304c@mojatatu.com>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
 <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
 <20160928112703.GW1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928112703.GW1876@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-09-28 07:27 AM, Cyrill Gorcunov wrote:
> On Wed, Sep 28, 2016 at 07:06:26AM -0400, Jamal Hadi Salim wrote:
>>>
>>> This structure is uapi, so anyone has complete rights to reference
>>> @pad in the userspace programs. Sure it would be more clear to remove
>>> the @pad completely, but if we choose so I think it's better to do
>>> on top instead and then if someone complain we can easily revert
>>> the single trivial commit instead of this big patch.
>>
>> I am conflicted.
>> A field labelled "pad" does not appear to be valid as "UAPI". It is
>> a cosmetic indicator. If you did sizeof() with or without it being
>> present the value doesnt change.
>
> I think you miss the point what I'm trying to say: currently end-user
> may have reference to this member (for any reason) and his program
> will compile and run. If we change the name the compilation procedure
> fails and this will break API. Yes, referrning @pad is bad idea for
> userspace code, and yes (!) better to simply rename it but lets do
> that later, on top, so that if we break something in userspace
> we could easily revert the oneline change.
>


I understood well your point;-> Maybe my response was not clear:
_nobody should be fscking fondling pad fields_ setting them or
otherwise.
Maybe let these programs fail. I asked if you knew any such app which
did anything with a pad field.

cheers,
jamal
