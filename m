From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] sit: fix panic with route cache in ip tunnels
Date: Wed, 19 Feb 2014 17:22:28 +0100
Message-ID: <5304DA44.2090305@6wind.com>
References: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <therbert@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:64081 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbaBSQWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 11:22:31 -0500
Received: by mail-wg0-f51.google.com with SMTP id n12so518057wgh.30
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 08:22:30 -0800 (PST)
In-Reply-To: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/02/2014 17:15, Nicolas Dichtel a =C3=A9crit :
> Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels").
>
> Because sit code does not call ip_tunnel_init(), the dst_cache was no=
t
> initialized.
>
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Patch is incomplete, please drop it.
