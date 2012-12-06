From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH net-next] net: fix some compiler warning in net/core/neighbour.c
Date: Thu, 06 Dec 2012 10:39:00 +0800
Message-ID: <50C00544.7060307@gmail.com>
References: <1354759444-4937-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Shan Wei <davidshan@tencent.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:64300 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2LFCjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:39:08 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2558321dak.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 18:39:08 -0800 (PST)
In-Reply-To: <1354759444-4937-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang said, at 2012/12/6 10:04:
> From: Cong Wang <amwang@redhat.com>
>=20
> net/core/neighbour.c:65:12: warning: 'zero' defined but not used [-Wu=
nused-variable]
> net/core/neighbour.c:66:12: warning: 'unres_qlen_max' defined but not=
 used [-Wunused-variable]
>=20
> These variables are only used when CONFIG_SYSCTL is defined,
> so move them under #ifdef CONFIG_SYSCTL.
>=20
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Shan Wei <davidshan@tencent.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Rapid response~~~ :-)
Same patch in my tree=EF=BC=8Cand i see your patch when prepare to subm=
it it.

Acked-by: Shan Wei <davidshan@tencent.com>


Best Regards
Shan Wei
