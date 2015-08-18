From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Tue, 18 Aug 2015 07:47:28 -0700
Message-ID: <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
	 <1439886649-24166-2-git-send-email-phil@nwl.cc>
	 <1439886649-24166-3-git-send-email-phil@nwl.cc>
	 <1439886649-24166-4-git-send-email-phil@nwl.cc>
	 <1439886649-24166-5-git-send-email-phil@nwl.cc>
	 <1439886649-24166-6-git-send-email-phil@nwl.cc>
	 <1439886649-24166-7-git-send-email-phil@nwl.cc>
	 <1439886649-24166-8-git-send-email-phil@nwl.cc>
	 <1439886649-24166-9-git-send-email-phil@nwl.cc>
	 <1439886649-24166-10-git-send-email-phil@nwl.cc>
	 <1439886649-24166-11-git-send-email-phil@nwl.cc>
	 <1439886649-24166-12-git-send-email-phil@nwl.cc>
	 <1439886649-24166-13-git-send-email-phil@nwl.cc>
	 <1439886649-24166-14-git-send-email-phil@nwl.cc>
	 <1439886649-24166-15-git-send-email-phil@nwl.cc>
	 <1439886649-24166-16-git-send-email-phil@nwl.cc>
	 <1439886649-24166-17-git-send-email-phil@nwl.cc>
	 <1439886649-24166-18-git-send-email-phil@nwl.cc>
	 <1439886649-24166-19-git-send-email-phil@nwl.cc>
	 <1439886649-24166-20-git-send-email-phil@nwl.cc>
	 <1439886649-24166-21-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34078 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbbHROra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 10:47:30 -0400
Received: by paccq16 with SMTP id cq16so90690506pac.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 07:47:29 -0700 (PDT)
In-Reply-To: <1439886649-24166-21-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-18 at 10:30 +0200, Phil Sutter wrote:
> Due to the introduction of IFF_NO_QUEUE, there is a better way for
> drivers to indicate that no qdisc should be attached by default. Though,
> the old convention can't be dropped since ignoring that setting would
> break drivers still using it. Instead, add a warning so out-of-tree
> driver maintainers get a chance to adjust their code before we finally
> get rid of any special handling of tx_queue_len == 0.

How an admin can remove qdisc on a regular ethernet device with this
schem ?

I was doing :

tc qdisc replace dev eth0 root pfifo
ifconfig eth0 txqueuelen 0
tc qdisc del dev eth0 root


I see nothing in your patches to avoid the DEPRECATED warning.
