From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 22:26:54 +0200
Message-ID: <1350246414.21172.17144.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:51543 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab2JNU1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 16:27:04 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1002290eaa.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 13:27:03 -0700 (PDT)
In-Reply-To: <1350246314.21172.17139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 22:25 +0200, Eric Dumazet wrote:

> 
> Hmm
> 
> pidof ntpd
> 
> should give you the pid of ntpd process : 368
> 
> So try 
> 
> lsof -p 368  # instead of lsof -p `pidof ntpd`

Also post :
