From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] gen_stats.c: Duplicate xstats buffer for later use
Date: Thu, 19 Feb 2015 15:47:03 -0500 (EST)
Message-ID: <20150219.154703.443300865954985533.davem@davemloft.net>
References: <1423867625-1509-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ignacy.gawedzki@green-communications.fr,
	David.Laight@aculab.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbBSUrH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:47:07 -0500
In-Reply-To: <1423867625-1509-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 13 Feb 2015 14:47:05 -0800

> From: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
>=20
> The gnet_stats_copy_app() function gets called, more often than not, =
with its
> second argument a pointer to an automatic variable in the caller's st=
ack.
> Therefore, to avoid copying garbage afterwards when calling
> gnet_stats_finish_copy(), this data is better copied to a dynamically=
 allocated
> memory that gets freed after use.
>=20
> [xiyou.wangcong@gmail.com: remove a useless kfree()]
>=20
> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Ugh, that's an ugly bug.

Applied and queued up for -stable, thanks.
