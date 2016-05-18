From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 14:18:31 -0700
Message-ID: <20160518211829.GA57390@ast-mbp.thefacebook.com>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
 <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com>
 <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
 <1463581068.18194.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34755 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbcERVSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 17:18:38 -0400
Received: by mail-pf0-f194.google.com with SMTP id 145so6052560pfz.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 14:18:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1463581068.18194.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 07:17:48AM -0700, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 15:28 +0200, Hannes Frederic Sowa wrote:
> 
> > I don't consider this a big thing, I just mentioned that we probably
> > shouldn't use prandom_u32 if the value somehow could leak to user space
> > and should be used for security.
> 
> Yes, I was mostly trying to understand if you had real security issues
> there or some general concerns ;)

agree with Eric. Frankly I wouldn't do it, but since it's a trivial
patch and if it makes security folks less worried then why not.
Acked-by: Alexei Starovoitov <ast@kernel.org>
