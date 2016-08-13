From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/5] net: add test for net cgroup
Date: Fri, 12 Aug 2016 21:38:27 -0700
Message-ID: <20160813043825.GC55856@ast-mbp.thefacebook.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <1470876798-4024-6-git-send-email-anaravaram@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com,
	weiwan@google.com, tom@herbertland.com
To: Anoop Naravaram <anaravaram@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33636 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcHMEia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 00:38:30 -0400
Content-Disposition: inline
In-Reply-To: <1470876798-4024-6-git-send-email-anaravaram@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 05:53:18PM -0700, Anoop Naravaram wrote:
> Created a file scripts/cgroup/net_cgroup_test.py that tests the
> functionality of the net cgroup as described in previous commit logs.
> 
> Signed-off-by: Anoop Naravaram <anaravaram@google.com>
> ---
>  scripts/cgroup/net_cgroup_test.py | 359 ++++++++++++++++++++++++++++++++++++++

thanks for the test. It's great to have one, but it is concerning that
the test doesn't cover all the knobs the previous patches introduce
which underlines the point of my concern for previous patches.
