From: Li Yu <raise.sail@gmail.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Fri, 11 May 2012 15:06:42 +0800
Message-ID: <4FACBA82.1070404@gmail.com>
References: <20120329074443.GB2098@minipsycho> <20120329.034957.655153582806618222.davem@davemloft.net> <20120329075410.GC2098@minipsycho> <1333008145.2325.275.camel@edumazet-glaptop> <20120329083149.GD2098@minipsycho> <1333010732.2325.339.camel@edumazet-glaptop> <20120329093158.GA2275@minipsycho.brq.redhat.com> <4FAC7C5B.40109@gmail.com> <20120511062257.GA1561@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com, matt@ozlabs.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51758 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2EKHGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 03:06:49 -0400
Received: by dady13 with SMTP id y13so2714821dad.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 00:06:48 -0700 (PDT)
In-Reply-To: <20120511062257.GA1561@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8811=E6=97=A5 14:22, Jiri Pirko =E5=86=99=
=E9=81=93:
> Fri, May 11, 2012 at 04:41:31AM CEST, raise.sail@gmail.com wrote:
>> =E4=BA=8E 2012=E5=B9=B403=E6=9C=8829=E6=97=A5 17:31, Jiri Pirko =E5=86=
=99=E9=81=93:
>>> Thu, Mar 29, 2012 at 10:45:32AM CEST, eric.dumazet@gmail.com wrote:
>>>> On Thu, 2012-03-29 at 10:31 +0200, Jiri Pirko wrote:
>>>>> Thu, Mar 29, 2012 at 10:02:25AM CEST, eric.dumazet@gmail.com wrot=
e:
>>>>>> On Thu, 2012-03-29 at 09:54 +0200, Jiri Pirko wrote:
>>>>>>
>>>>>>> Yep, I'm aware. I must admit that the JIT code scares me a litt=
e :(
>>>>>>>
>>>>>>
>>>>>> If you add a new XOR instruction in interpreter only, JIT compil=
er will
>>>>>> automatically aborts, so no risk.
>>>>>>
>>>>>> Each arch maintainer will add the support for the new instructio=
ns as
>>>>>> separate patches.
>>>>>>
>>>>>> So you can focus on net/core/filter.c file only.
>>>>>>
>>>>>
>>>>> Ok - I can do this for 2). But for 3) JITs need to be modified. S=
o I
>>>>> would like to kindly ask you and Matt if you can do this modifica=
tion so
>>>>> bpf_func takes pointer to mem (scratch store) as second parameter=
=2E I'm
>>>>> sure it's very easy for you to do.
>>>>
>>>> I am not sure why you want this.
>>>>
>>>> This adds register pressure (at least for x86) ...
>>>
>>> Well I think that there would become handy to be able to pass some =
data
>>> to bpf_func (other than skb). But it's just an idea.
>>>
>>
>> Hi, Jiri Pirko, any progress of extended BPF? :)
>>
>> I am interesting in 3) much. For my requirements,
>> it just only need BPF has ability to handle arbitrary
>> "pre-filled memory area", but not handle both a skb and
>> such a memory area at same time, so I think that register
>> pressure should not be become the performance bottleneck
>> here.
>>
>> Otherwise, I must construct a fake sk_buff to execute filter
>> feature, it is ugly, isn't it?
>>
>> I guess that Nuno Martins's requirements also are similar.
>>
>> And, I also would like join this project, if you need.
>
> For my needs it turned out I do not need pre-filled memory. So I drop=
ped
> that point.
>

Oops, I may try to work on this, would you like send
a copy of your sk-unattached filters patch to me ?
I think that it is a good start.

Thanks for your time.

Yu

>>
>> Thanks
>>
>> Yu
>>
>>>>
>>>>
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>
