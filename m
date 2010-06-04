From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: tcp: fix rps_sock_flow_table table updates
Date: Fri, 4 Jun 2010 08:15:10 -0700
Message-ID: <AANLkTil2FPtr9PDoY4MGOpSdEkLW4qJesqzzjJr5FCwk@mail.gmail.com>
References: <1275591838.2533.37.camel@edumazet-laptop>
	<20100603.200721.59663365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:31026 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab0FDPPP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 11:15:15 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o54FFCrw021653
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 08:15:13 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe12.cbf.corp.google.com with ESMTP id o54FFBXU013886
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 08:15:11 -0700
Received: by pvh11 with SMTP id 11so781216pvh.13
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 08:15:11 -0700 (PDT)
In-Reply-To: <20100603.200721.59663365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good to me.   Thanks Eric.

Tom

On Thu, Jun 3, 2010 at 8:07 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Jun 2010 21:03:58 +0200
>
> > I believe a moderate SYN flood attack can corrupt RFS flow table
> > (rps_sock_flow_table), making RPS/RFS much less effective.
> =A0...
> > This patch moves sock_rps_save_rxhash() to a sock locked section,
> > and only for non LISTEN sockets.
>
> This looks good to me.
>
> Tom, please review.
