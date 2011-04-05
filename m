From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output routes."
Date: Tue, 05 Apr 2011 23:11:01 +0900
Message-ID: <877hb87pqi.fsf@devron.myhome.or.jp>
References: <87oc4kj1bt.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:57146 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab1DEOLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 10:11:06 -0400
In-Reply-To: <87oc4kj1bt.fsf@devron.myhome.or.jp> (OGAWA Hirofumi's message of
	"Tue, 05 Apr 2011 22:05:10 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

> Hi,
>
> ipv4: Set rt->rt_iif more sanely on output routes.
> (1018b5c01636c7c6bda31a719bda34fc631db29a)
>
> The above patch seems to be caused of avahi breakage.
>
> I'm not debugging fully though, avahi is using IP_PKTINFO and checking
> in_pktinfo->ipi_ifindex > 0.
>
> And if I reverted above patch, it seems to fix avahi's IP_PKTINFO problem.
>
> Ideas?

BTW, simple revert seems to break routing or something instead.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
