From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] block/drbd: use nla_put_u64_64bit()
Date: Tue, 3 May 2016 11:28:41 +0200
Message-ID: <57286F49.8050107@6wind.com>
References: <20160426121850.GC20950@soda.linbit>
 <1462265435-15141-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: lars.ellenberg@linbit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38771 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725AbcECJ2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 05:28:45 -0400
Received: by mail-wm0-f48.google.com with SMTP id g17so27708606wme.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 02:28:45 -0700 (PDT)
In-Reply-To: <1462265435-15141-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/05/2016 10:50, Nicolas Dichtel a =C3=A9crit :
> I had to define an intermediate function (nla_magic_put_flag()) becau=
se
> handlers in genl_magic_struct.h expect a function with three argument=
s.
>=20
> Note that this patch is only compile-tested.
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Please, drop it. I will send another version to handle all cases.
