From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Fix wrong order of ip_rt_get_source() and update
 iph->daddr.
Date: Fri, 10 Feb 2012 08:04:10 +0100
Message-ID: <1328857450.2436.9.camel@edumazet-laptop>
References: <4F34BDAD.8080608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:48570 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab2BJHEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:04:13 -0500
Received: by wics10 with SMTP id s10so1776543wic.19
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2012 23:04:12 -0800 (PST)
In-Reply-To: <4F34BDAD.8080608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 14:48 +0800, Li Wei a =C3=A9cri=
t :
> Need to update iph->daddr before ip_rt_get_source(), otherwise
> we may get a wrong src.
>=20

It would be nice that patch submitters try to pinpoint bug origin in
changelog, to ease patch review and stable submissions.

Is it coming from ac8a48106be49c422575ddc7531b776f8eb49610 (ipv4: Save
nexthop address of LSRR/SSRR option to IPCB.) added in 3.2, or is it
something needing a backport in some other way in old kernels ?

Thanks !
