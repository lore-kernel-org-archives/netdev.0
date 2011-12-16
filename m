From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 18:14:46 +0100
Message-ID: <1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>
	   <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
	  <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1112161043080.26765@router.home>
	 <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1112161053030.26765@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57863 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab1LPROt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 12:14:49 -0500
Received: by wgbds13 with SMTP id ds13so3399728wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 09:14:48 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112161053030.26765@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 10:55 -0600, Christoph Lameter=
 a =C3=A9crit :
> On Fri, 16 Dec 2011, Eric Dumazet wrote:
>=20
> > Or we could use a hierarchical split : Say 16 (or 32 or 64) cpus sh=
are
> > same counters (must be atomic if NR_CPUS > 16/32/64)
>=20
> Then you'd need to have locking or full atomic operations for the
> counters.

I mentioned that : "(must be atomic if NR_CPUS > 16/32/64)"


>  Reduction of network processing to a set of processors also will
> have other beneficial effects in addition to cache hotness. It would
> removing OS jitter etc etc.
>=20

You already can do that right now, with or without hardware help.

See numerous improvements in this area (RPS/RFS/RSS/XPS ... in
Documentation/networking/scaling.txt)


> > percpu_alloc() -> percpugroup_alloc()
>=20
> Sounds like a per cpuset/cgroup allocation?
>=20
