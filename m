From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v6 1/1] ipv6: add support of equal cost multipath
 (ECMP)
Date: Tue, 02 Oct 2012 18:06:28 +0200
Message-ID: <506B1104.7030908@6wind.com>
References: <1349110077.7740.23.camel@joe-AO722> <1349193767-3992-1-git-send-email-nicolas.dichtel@6wind.com> <1349193767-3992-2-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59857 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab2JBQGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 12:06:41 -0400
Received: by eekb15 with SMTP id b15so3237314eek.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 09:06:40 -0700 (PDT)
In-Reply-To: <1349193767-3992-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2012 18:02, Nicolas Dichtel a =C3=A9crit :
> Each nexthop is added like a single route in the routing table. All r=
outes
> that have the same metric/weight and destination but not the same gat=
eway
> are considering as ECMP routes. They are linked together, through a l=
ist called
> rt6i_siblings.
>
> ECMP routes can be added in one shot, with RTA_MULTIPATH attribute or=
 one after
> the other (in both case, the flag NLM_F_EXCL should not be set).
>
> The patch is based on a previous work from
> Luc Saillard <luc.saillard@6wind.com>.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
I forget to run checkpatch.pl, some lines are over 80 columns. I will f=
ix it in=20
the v7 with other comments (if any).
