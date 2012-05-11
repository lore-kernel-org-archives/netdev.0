From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Fri, 11 May 2012 08:22:57 +0200
Message-ID: <20120511062257.GA1561@minipsycho>
References: <20120329074443.GB2098@minipsycho>
 <20120329.034957.655153582806618222.davem@davemloft.net>
 <20120329075410.GC2098@minipsycho>
 <1333008145.2325.275.camel@edumazet-glaptop>
 <20120329083149.GD2098@minipsycho>
 <1333010732.2325.339.camel@edumazet-glaptop>
 <20120329093158.GA2275@minipsycho.brq.redhat.com>
 <4FAC7C5B.40109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com, matt@ozlabs.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757919Ab2EKGXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 02:23:32 -0400
Content-Disposition: inline
In-Reply-To: <4FAC7C5B.40109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, May 11, 2012 at 04:41:31AM CEST, raise.sail@gmail.com wrote:
>=E4=BA=8E 2012=E5=B9=B403=E6=9C=8829=E6=97=A5 17:31, Jiri Pirko =E5=86=
=99=E9=81=93:
>>Thu, Mar 29, 2012 at 10:45:32AM CEST, eric.dumazet@gmail.com wrote:
>>>On Thu, 2012-03-29 at 10:31 +0200, Jiri Pirko wrote:
>>>>Thu, Mar 29, 2012 at 10:02:25AM CEST, eric.dumazet@gmail.com wrote:
>>>>>On Thu, 2012-03-29 at 09:54 +0200, Jiri Pirko wrote:
>>>>>
>>>>>>Yep, I'm aware. I must admit that the JIT code scares me a litte =
:(
>>>>>>
>>>>>
>>>>>If you add a new XOR instruction in interpreter only, JIT compiler=
 will
>>>>>automatically aborts, so no risk.
>>>>>
>>>>>Each arch maintainer will add the support for the new instructions=
 as
>>>>>separate patches.
>>>>>
>>>>>So you can focus on net/core/filter.c file only.
>>>>>
>>>>
>>>>Ok - I can do this for 2). But for 3) JITs need to be modified. So =
I
>>>>would like to kindly ask you and Matt if you can do this modificati=
on so
>>>>bpf_func takes pointer to mem (scratch store) as second parameter. =
I'm
>>>>sure it's very easy for you to do.
>>>
>>>I am not sure why you want this.
>>>
>>>This adds register pressure (at least for x86) ...
>>
>>Well I think that there would become handy to be able to pass some da=
ta
>>to bpf_func (other than skb). But it's just an idea.
>>
>
>Hi, Jiri Pirko, any progress of extended BPF? :)
>
>I am interesting in 3) much. For my requirements,
>it just only need BPF has ability to handle arbitrary
>"pre-filled memory area", but not handle both a skb and
>such a memory area at same time, so I think that register
>pressure should not be become the performance bottleneck
>here.
>
>Otherwise, I must construct a fake sk_buff to execute filter
>feature, it is ugly, isn't it?
>
>I guess that Nuno Martins's requirements also are similar.
>
>And, I also would like join this project, if you need.

=46or my needs it turned out I do not need pre-filled memory. So I drop=
ped
that point.

>
>Thanks
>
>Yu
>
>>>
>>>
>>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
