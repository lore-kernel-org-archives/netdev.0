From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] inet_diag: fix panic when unload inet_diag
Date: Tue, 25 Sep 2012 15:27:17 +0800
Message-ID: <50615CD5.4040801@cn.fujitsu.com>
References: <1348541310-31913-1-git-send-email-gaofeng@cn.fujitsu.com> <1348555011.26828.2031.camel@edumazet-glaptop> <50615B30.80901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com, jengelh@inai.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:40614 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab2IYH1Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 03:27:25 -0400
In-Reply-To: <50615B30.80901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8825=E6=97=A5 15:20, Gao feng =E5=86=99=
=E9=81=93:
> It's need to modify netlink_dump_start not only wrap netlink_dump_sta=
rt.

maybe it's better to add a struct module *module in struct netlink_call=
back..
