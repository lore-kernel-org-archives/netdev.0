From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: install nf_nat.h and related headers to
 INSTALL_HDR_PATH
Date: Sat, 3 Sep 2011 21:41:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1109032141040.30017@frira.zrqbmnf.qr>
References: <1315075784-10163-1-git-send-email-basile@opensource.dyc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, kaber@trash.net, blueness@gentoo.org,
	gurligebis@gentoo.org, base-system@gentoo.org, kernel@gentoo.org,
	toolchain@gentoo.org, mchehab@redhat.com, hverkuil@xs4all.nl,
	laurent.pinchart@ideasonboard.com, arnd@arndb.de,
	eparis@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: "Anthony G. Basile" <basile@opensource.dyc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:49812 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750Ab1ICTlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Sep 2011 15:41:37 -0400
In-Reply-To: <1315075784-10163-1-git-send-email-basile@opensource.dyc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 2011-09-03 20:49, Anthony G. Basile wrote:

>Currently nf_nat.h, nf_conntrack_tuple.h and related headers under
>include/net/netfilter are not installed as part of the public kernel
>headers.   However, there are userland applications, other than iptables
>which ships with its own headers, which need these to make use of NAT in
>the kernel's netfilter API.  For example, miniupnpd, requires them and is
>forced to search /usr/src/linux when building.
>
>This patch makes these headers public by installing them in
>INSTALL_HDR_PATH.
>
>See: https://bugs.gentoo.org/376873
>
>Signed-off-by: Anthony G. Basile <blueness@gentoo.org>

>@@ -0,0 +1,6 @@
>+header-y += nf_nat.h
>+header-y += nf_conntrack.h
>+header-y += nf_conntrack_tuple.h
>+header-y += nf_conntrack_extend.h
>+header-y += ipv4/
>+header-y += ipv6/

Should not the to-be-exported files better go into linux/ instead?
