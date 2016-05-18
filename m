From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 07:17:48 -0700
Message-ID: <1463581068.18194.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
	 <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com>
	 <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34846 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227AbcERORw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 10:17:52 -0400
Received: by mail-pa0-f65.google.com with SMTP id rw9so5063489pab.2
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 07:17:52 -0700 (PDT)
In-Reply-To: <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 15:28 +0200, Hannes Frederic Sowa wrote:

> I don't consider this a big thing, I just mentioned that we probably
> shouldn't use prandom_u32 if the value somehow could leak to user space
> and should be used for security.

Yes, I was mostly trying to understand if you had real security issues
there or some general concerns ;)
