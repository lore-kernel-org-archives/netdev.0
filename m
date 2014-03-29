From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] netpoll: Cleanups and fixes
Date: Sat, 29 Mar 2014 18:01:03 -0400 (EDT)
Message-ID: <20140329.180103.485295949876068582.davem@davemloft.net>
References: <20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbaC2WBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:01:05 -0400
In-Reply-To: <87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Mar 2014 15:35:20 -0700

> This should be a small set of safe cleanups and fixes to netpoll.
> 
> The fixes are vlan headers are now always inserted when needed, and
> napi polling is always avoided when network devices are closed.
> 
> There are a bunch of little cleanups removing unnecessary code, fixing
> function naming, not taking unnecessary locks and removing general
> silliness.

Looks good, series applied, thanks Eric.
