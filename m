From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 16 Aug 2016 10:22:25 -0600
Message-ID: <584b7d33-d30a-3dab-cc8a-9444cab200a9@cumulusnetworks.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net>
 <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net>
 <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <04a393c9-39f8-8d73-3476-928732e5b193@cumulusnetworks.com>
 <ed271d49-e796-ebaa-2e71-35711710fd49@miraclelinux.com>
 <CAKD1Yr3LNv+hDm0HfxYiGvotiTYab9W-+5R0OUjinF-tdwKy1g@mail.gmail.com>
 <642d0eef-4f62-f63c-9db5-3d890bb942df@miraclelinux.com>
 <CAKD1Yr3J8NMZkVXdUGZNeA=nRdWWKcq+0JRM57B_Q7WsCkTgGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34929 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbcHPQWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 12:22:32 -0400
Received: by mail-pf0-f171.google.com with SMTP id x72so29098365pfd.2
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 09:22:32 -0700 (PDT)
In-Reply-To: <CAKD1Yr3J8NMZkVXdUGZNeA=nRdWWKcq+0JRM57B_Q7WsCkTgGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/16 9:21 AM, Lorenzo Colitti wrote:
> I also don't see how the VRF behaviour where sk_bound_dev_if sets the
> master interface and pktinto selects the slave interface" can be made
> to work at all in the presence of scoped addresses. I don't see any
> way to support a socket bound to fe80::1%eth0 and a socket bound to
> fe80::1%wlan0 in the same VRF.

It does not work with sk_bound_dev_if set; works fine without it.
