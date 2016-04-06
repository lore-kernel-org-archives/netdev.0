From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 16:07:43 -0400
Message-ID: <CAHC9VhTCGL5PZoRxbQ4kkTR28CF5xzw+z2yrLJVfYP=Km55sdg@mail.gmail.com>
References: <CAHC9VhQS+LfPbj0UuKFiVCW7LKthJmgOt08MvCiwKjTZZYstxA@mail.gmail.com>
	<20160406.142316.1728426867290841888.davem@davemloft.net>
	<CAHC9VhT0444cEDKsfww7Yj22svSFOfY4ersVhh8up9ZrZ_8rng@mail.gmail.com>
	<20160406.153955.2244652846180310527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pabeni@redhat.com, linux-security-module@vger.kernel.org,
	James Morris <james.l.morris@oracle.com>, agruenba@redhat.com,
	Stephen Smalley <sds@tycho.nsa.gov>, fw@strlen.de,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34373 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbcDFUHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:07:45 -0400
Received: by mail-oi0-f65.google.com with SMTP id q133so8821212oib.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 13:07:44 -0700 (PDT)
In-Reply-To: <20160406.153955.2244652846180310527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 3:39 PM, David Miller <davem@davemloft.net> wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Wed, 6 Apr 2016 14:36:43 -0400
>
>> On Wed, Apr 6, 2016 at 2:23 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Paul Moore <paul@paul-moore.com>
>>> Date: Wed, 6 Apr 2016 10:07:27 -0400
>>>
>>>> "While marking the LSM hook structure doesn't directly affect the
>>>> SELinux netfilter hooks, once we remove the ability to deregister the
>>>> LSM hooks we will have no need to support deregistering netfilter
>>>> hooks and I expect we will drop that functionality as well to help
>>>> decrease the risk of tampering."
>>>
>>> This is not a reasonable postiion.
>>>
>>> The performance implications are non-trivial for using netfilter hooks
>>> when they aren't actually needed.
>>
>> With all due respect, I think you've taken what I consider to be some
>> unreasonable positions when it comes to the network stack and LSMs in
>> the past.  We have different perspectives and different priorities as
>> a result, from my perspective the security advantage gained by
>> eliminating the ability to disable SELinux at runtime is more
>> important.
>
> SELinux folks seem to get rather upset to people outright disabling
> the facility, but many users still do exactly that.

My opinion is that SELinux isn't for everyone; I think it would be
great if everyone enabled it, but I recognize that it isn't the best
fit for everyone's needs.  If users want to disable it in order to
better meet their needs, who am I to argue?

Or perhaps I should be upset?  I dunno, please tell me how I should
feel.  Like most people, I *love* when I'm told how I should react.

> In my opinion, it's uncompromising positions like the one you are
> having here is part of the reason that issue will continue.

Once again, I suspect this all a matter of perspective; from my point
of view the SELinux code has compromised quite a lot, especially in
the case of the networking controls.

> It is not AND, it's an OR, people want choice, and if you don't give
> it to them they will find a way to achieve what they want with or
> without your help.  And you might not like what they come up with.
>
> If distributions are turning SELinux on by default, then we have to
> care about whather netfilter performance should suffer for facilities
> which are unused.

I think you've made your point known, and I believe I've been clear
about the reasoning behind my decision as well.  I would suggest we
leave it at that until/unless someone has something constructive to
add to the conversation.

-- 
paul moore
www.paul-moore.com
