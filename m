From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 08:18:16 -0400
Message-ID: <CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	<1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:50174 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbaE1MSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 08:18:18 -0400
Received: by mail-la0-f42.google.com with SMTP id el20so7346976lab.29
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 05:18:17 -0700 (PDT)
In-Reply-To: <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 9:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Last time I checked, we were spending _lot_ of time in check_lifetime()

Although check_lifetime() itself did not light up in my
perf output, i see your point- it has a few ifa_list walks
that might end up being expensive - but these are static
IPv4 addresses- they should be marked IFA_F_PERMANENT,
right? That's probably why they did not show up in my perf output?

--Sowmini
