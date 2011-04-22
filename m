From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: allow user to change NETIF_F_HIGHDMA
Date: Fri, 22 Apr 2011 09:38:50 -0700
Message-ID: <20110422093850.13df40ce@nehalam>
References: <20110422163116.37DE613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58838 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756188Ab1DVQiw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 12:38:52 -0400
In-Reply-To: <20110422163116.37DE613909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Apr 2011 18:31:16 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> NETIF_F_HIGHDMA is like any other TX offloads, so allow user to toggl=
e it.
> This is needed later for bridge and bonding convertsion to hw_feature=
s.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

This was meant to be a hidden flag that that reflects capability of
hardware. Do yo really mean to allow user to disable it via ethtool?
