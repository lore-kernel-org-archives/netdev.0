From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 20:56:10 -0700
Message-ID: <1414036570.2094.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	 <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <544873DF.1040403@gmail.com>
	 <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33304 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaJWD4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 23:56:11 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so292853pad.5
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 20:56:11 -0700 (PDT)
In-Reply-To: <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 20:51 -0700, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 20:19 -0700, Alexander Duyck wrote:
> 
> > Couldn't __netdev_alloc_frag() be forked into two functions, one that is
> > only called from inside the NAPI context and one that is called for all
> > other contexts?  It would mean having to double the number of pages
> > being held per CPU, but I would think something like that would be doable.
> 
> Possibly, but this looks like code bloat for me.
> 
> On my hosts, this hard irq masking is pure noise.
> 
> What CPU are you using Alexander ?

Sorry, the question was for Alexei ;)
