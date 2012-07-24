From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Tue, 24 Jul 2012 07:06:47 +0200
Message-ID: <1343106407.2626.11038.camel@edumazet-glaptop>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?ISO-8859-1?Q?Villac=EDs?= Lasso
	<a_villacis@palosanto.com>, Josh Boyer <jwboyer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43453 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab2GXFGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 01:06:53 -0400
Received: by wibhm11 with SMTP id hm11so3602134wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 22:06:51 -0700 (PDT)
In-Reply-To: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
>=20
> First it appears in bisection, then reverting it solves the usual
> netdev watchdog problem for different people. I don't have a proper
> fix yet so get rid of it.
>=20
> Bisected-and-reported-by: Alex Villac=C3=ADs Lasso <a_villacis@palosa=
nto.com>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Josh Boyer <jwboyer@redhat.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---

bisection is not always the right way to qualify a problem.

BQL in itself had some fixes coming _after_ commit 036dafa28da1e2565

Is there an easy way to reproduce the problem ?

Thanks
