From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 01:24:17 +0900
Message-ID: <CAKD1Yr03OGoOGtCB9JTCkpQhiPGh+wZRMB96YNSy4WzR2ckTow@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com> <39efdc37-88cc-34c4-ad64-2f13fd0bc4a2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34174 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbcHHQYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:24:45 -0400
Received: by mail-yw0-f174.google.com with SMTP id z8so308018861ywa.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:24:39 -0700 (PDT)
In-Reply-To: <39efdc37-88cc-34c4-ad64-2f13fd0bc4a2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 12:27 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> > -     if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
> > -             fl6.flowi6_oif = np->mcast_oif;
> > -     else if (!fl6.flowi6_oif)
> > -             fl6.flowi6_oif = np->ucast_oif;
> > -
>
> That code removal is contrary to your patch description regarding flowi6_oif.

Which code removal? The one I quote above? That code wasn't removed,
it was moved to above the initialization of flowi6.
