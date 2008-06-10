From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: blackfin drivers/net/smc91x.c build error
Date: Tue, 10 Jun 2008 13:13:52 -0400
Message-ID: <8bd0f97a0806101013w42b9028j5dfa38d654f3d05f@mail.gmail.com>
References: <20080606162212.GC2201@cs181133002.pp.htv.fi>
	 <8bd0f97a0806061252n1cf5ee33i40ddf9f55588e242@mail.gmail.com>
	 <20080610135349.GA30792@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bryan Wu" <cooloney@kernel.org>, "Jeff Garzik" <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:53828 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbYFJRNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 13:13:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so992702rvb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 10:13:52 -0700 (PDT)
In-Reply-To: <20080610135349.GA30792@cs181133002.pp.htv.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 9:53 AM, Adrian Bunk wrote:
> On Fri, Jun 06, 2008 at 03:52:09PM -0400, Mike Frysinger wrote:
>> On Fri, Jun 6, 2008 at 12:22 PM, Adrian Bunk wrote:
>> > drivers/net/smc91x.c fails as follows on blackfin:
>> > ...
>> >  CC      drivers/net/smc91x.o
>> > ...
>> > /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/smc91x.c:1863:36: error: macro "SMC_GET_MAC_ADDR" passed 2 arguments, but takes just 1
>> > ...
>>
>> it's a known issue (been known for quite a long time actually).  Bryan
>> has brought this up in the past already.
>
> Is my suggestion of reverting commit 099c736a470c8080a166e7a089f1e48e15f9947c
> correct or how else should it be resolved?

Bryan is taking care of it ... it may just stay broken in favor of
waiting for the merge from the net tree.

> This issue is the only remaining problem preventing that all blackfin
> defconfigs will compile in 2.6.26...

not really true.  but otherwise, failures dont go unnoticed as we have
automated nightly builds for all the relevant trees.
-mike
