From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in TLB mode.
Date: Thu, 10 Jul 2014 10:25:01 +0200
Message-ID: <CAHo-OoxZaRdvg7yD2KBcYz5Eb5B+4TdoZc-Db+3q4T8uHOVduA@mail.gmail.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
	<20140709102441.GB1227@redhat.com>
	<53BD18A7.6090109@redhat.com>
	<20140709120437.GC1227@redhat.com>
	<1404911849.3515.28.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140709132709.GA11974@redhat.com>
	<CAF2d9ji-E4Og94X+NbcGs=WKSemryy6-WoPKzSVCaM13Rqjiug@mail.gmail.com>
	<CAF2d9jhJuisK1TmePtz-X79-oDmQHGHhvipAVAE=5Y2cu7tSEg@mail.gmail.com>
	<53BDAF1A.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:65125 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbaGJIZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:25:03 -0400
Received: by mail-qg0-f49.google.com with SMTP id 63so479640qgz.22
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:25:02 -0700 (PDT)
In-Reply-To: <53BDAF1A.4050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Please note that I got this assert-fail on 3.10 kernel and haven't
>> verified if things have changed in mii_monitor context since then.
>>
> Okay, this is definitely it. Moreover I cannot find
> "bond_handle_link_change" function in any bonding version, google search
> also shows up empty.
>
> Could you please test this patch with the tree that it is intended for ?
> I'm pretty certain that there won't be any problem.
>
> And one more thing, please update the CC list, Jay's email now is:
> j.vosburgh@gmail.com
> according to the MAINTAINERS file.

Mahesh you're running into one of the 2 or 3 internal bonding mode
changes that haven't been upstreamed.
Some sort of lacp churn machine and faster/better link up/down/change
notification propagation are among them.
We really should clean those up and get them submitted.

You should probably do this development on upstream 3.15 ;-)

- Maciej
