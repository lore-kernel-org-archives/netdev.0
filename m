From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v5 net-next 00/27] bonding: use neighbours instead of
 own lists
Date: Thu, 26 Sep 2013 16:02:56 -0400 (EDT)
Message-ID: <20130926.160256.371775655310136113.davem@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, fubar@us.ibm.com,
	andy@greyhouse.net, dm@chelsio.com, kaber@trash.net,
	edumazet@google.com, alexander.h.duyck@intel.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854Ab3IZUDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 16:03:12 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed, 25 Sep 2013 09:20:05 +0200

> This patchset introduces all the needed infrastructure, on top of current
> adjacent lists, to be able to remove bond's slave_list/slave->list. The
> overhead in memory/CPU is minimal, and after the patchset bonding can rely
> on its slave-related functions, given the proper locking. I've done some
> netperf benchmarks on a vm, and the delta was about 0.1gbps for 35gbps as a
> whole, so no speed fluctuations.
> 
> It also automatically creates lower/upper and master symlinks in dev's
> sysfs directory.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Dimitris Michailidis <dm@chelsio.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Ok, looks good to me, series applied, thanks!
