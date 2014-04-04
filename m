From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 15:36:11 +0200
Message-ID: <533EB54B.9060505@6wind.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us> <533EAC70.2070604@6wind.com> <20140404132300.GA2892@minipsycho.brq.redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	vfalico@redhat.com, stephen@networkplumber.org, hkchu@google.com,
	dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:35003 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872AbaDDNgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:36:15 -0400
Received: by mail-we0-f171.google.com with SMTP id t61so3445862wes.16
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 06:36:13 -0700 (PDT)
In-Reply-To: <20140404132300.GA2892@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2014 15:23, Jiri Pirko a =E9crit :
> Fri, Apr 04, 2014 at 02:58:24PM CEST, nicolas.dichtel@6wind.com wrote=
:
>> Le 04/04/2014 14:20, Jiri Pirko a =E9crit :
>>> The priv is used now by af_packet. Rename it to make it useable for
>>> others as well. Also, introduce packet_id_match to move the sk matc=
hing
>> >from skb_loop_sk to af_packet code where it belongs.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>   include/linux/netdevice.h |  2 +-
>>>   net/core/dev.c            |  4 +---
>>>   net/packet/af_packet.c    | 22 +++++++++++++++-------
>>>   3 files changed, 17 insertions(+), 11 deletions(-)
>> Hmm, net-next is closed I think.
>
> I did not see the announcement, maybe I missed it.
http://www.spinics.net/lists/netdev/msg278012.html
