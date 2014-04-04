From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 4 Apr 2014 15:23:00 +0200
Message-ID: <20140404132300.GA2892@minipsycho.brq.redhat.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
 <533EAC70.2070604@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	vfalico@redhat.com, stephen@networkplumber.org, hkchu@google.com,
	dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56457 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbaDDNXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:23:04 -0400
Received: by mail-wi0-f178.google.com with SMTP id bs8so1243666wib.11
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 06:23:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <533EAC70.2070604@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Apr 04, 2014 at 02:58:24PM CEST, nicolas.dichtel@6wind.com wrote=
:
>Le 04/04/2014 14:20, Jiri Pirko a =E9crit :
>>The priv is used now by af_packet. Rename it to make it useable for
>>others as well. Also, introduce packet_id_match to move the sk matchi=
ng
>>from skb_loop_sk to af_packet code where it belongs.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  include/linux/netdevice.h |  2 +-
>>  net/core/dev.c            |  4 +---
>>  net/packet/af_packet.c    | 22 +++++++++++++++-------
>>  3 files changed, 17 insertions(+), 11 deletions(-)
>Hmm, net-next is closed I think.

I did not see the announcement, maybe I missed it.
