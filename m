From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Mon, 21 Apr 2008 10:21:59 -0400
Message-ID: <1208787720.12249.207.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>
	 <480A21AF.1040405@trash.net> <1208692128.12249.26.camel@localhost>
	 <480C7F68.7090105@trash.net> <1208783227.12249.172.camel@localhost>
	 <480C992C.6050406@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:1853 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758637AbYDUOWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 10:22:19 -0400
Received: by wa-out-1112.google.com with SMTP id m16so3145188waf.23
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 07:22:17 -0700 (PDT)
In-Reply-To: <480C992C.6050406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-04 at 15:39 +0200, Patrick McHardy wrote:

> 
> Yes, that would be nice, the iproute netlink infrastructure is really
> lagging behind. 

Agreed.

> I'm not sure which way would be preferrable, build
> something new on top of libnl without disturbing existing users or
> gradually port iproute on top of libnl, probably starting with the
> netlink infrastructure.

I would say build something new would be the proper way to go. Maintain
output of ip/tc/ifconfig/route and phase them out slowly.

> Yes, its a bit overwhelming at the beginning because of all
> those knobs, but the simple things are actually real easy :)

The majority of new users out there may not have the same challenges i
had:
I wanted to do some simple things in a short period; i knew how to use
libnetlink - i thought the mapping would be easy to follow from
libnetlink to libnl; after a few hours, rather than investing more time
i found it easier to update things on top of libnetlink.
People who are totaly starting may find it easier to learn libnl first.
I certainly do plan to poke fingers at libnl - i just happen to have
something that works.

cheers,
jamal

