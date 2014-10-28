From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Mon, 27 Oct 2014 17:16:49 -0700
Message-ID: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141025141038.26fa5ac2@uryu.home.lan>
	 <20141025214448.GB28407@breakpoint.cc>	<544D8386.9030609@redhat.com>
	 <1414370826.16231.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <544E06CF.30709@redhat.com> <20141027155938.28248b5e@gentoo.org>
	 <544ECFFA.8080402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McLean <chutzpah@gentoo.org>,
	Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:57934 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbaJ1AQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 20:16:50 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so4628875pdb.25
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 17:16:50 -0700 (PDT)
In-Reply-To: <544ECFFA.8080402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 00:06 +0100, Nikolay Aleksandrov wrote:

> Great! Thanks for testing.
> As I said earlier we have a valid case that can hit the WARN_ON in
> inet_evict_frag().
> Anyhow, Eric would you mind posting the patch officially ?
> If you'd like me to remove the WARN_ON() in a separate one just let me
> know, otherwise feel free to remove it in the fix for the race.

Please Nikolay take ownership of this patch, I am busy on other stuff at
the moment, thanks !
