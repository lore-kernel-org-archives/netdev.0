From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] MAINTAINERS: Add ehea driver as Supported
Date: Wed, 01 Sep 2010 20:48:41 +0200
Message-ID: <1283366921.2484.8.camel@edumazet-laptop>
References: <1283365403-20877-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, THEMANN@de.ibm.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34917 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab0IASss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 14:48:48 -0400
Received: by wwb13 with SMTP id 13so154620wwb.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 11:48:46 -0700 (PDT)
In-Reply-To: <1283365403-20877-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 septembre 2010 =C3=A0 15:23 -0300, leitao@linux.vnet.ibm=
=2Ecom a
=C3=A9crit :
> This change just add the IBM eHEA 10Gb network drivers as supported.
>=20
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Hi Breno.

This reminds me something I noticed in this driver.

In receive path, it unconditionally sets skb->ip_summed to
CHECKSUM_UNECESSARY, for _all_ frames, and this seems very suspect.

Shouldnt cqe->inet_checksum_value be checked or something ?

Are frames with bad checksum completely ignored at hardware level ?

Thanks


