From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 14:36:43 -0400
Message-ID: <CAHC9VhT0444cEDKsfww7Yj22svSFOfY4ersVhh8up9ZrZ_8rng@mail.gmail.com>
References: <CAHC9VhS6aJdPR6xTH2-ehikS5qvj6jFbZAUtzoBXp+WC9Ugi=Q@mail.gmail.com>
	<1459951424.5425.12.camel@redhat.com>
	<CAHC9VhQS+LfPbj0UuKFiVCW7LKthJmgOt08MvCiwKjTZZYstxA@mail.gmail.com>
	<20160406.142316.1728426867290841888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pabeni@redhat.com, linux-security-module@vger.kernel.org,
	James Morris <james.l.morris@oracle.com>, agruenba@redhat.com,
	Stephen Smalley <sds@tycho.nsa.gov>, fw@strlen.de,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33801 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcDFSgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 14:36:44 -0400
Received: by mail-oi0-f66.google.com with SMTP id q133so8459946oib.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 11:36:44 -0700 (PDT)
In-Reply-To: <20160406.142316.1728426867290841888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 2:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Wed, 6 Apr 2016 10:07:27 -0400
>
>> "While marking the LSM hook structure doesn't directly affect the
>> SELinux netfilter hooks, once we remove the ability to deregister the
>> LSM hooks we will have no need to support deregistering netfilter
>> hooks and I expect we will drop that functionality as well to help
>> decrease the risk of tampering."
>
> This is not a reasonable postiion.
>
> The performance implications are non-trivial for using netfilter hooks
> when they aren't actually needed.

With all due respect, I think you've taken what I consider to be some
unreasonable positions when it comes to the network stack and LSMs in
the past.  We have different perspectives and different priorities as
a result, from my perspective the security advantage gained by
eliminating the ability to disable SELinux at runtime is more
important.

-- 
paul moore
www.paul-moore.com
