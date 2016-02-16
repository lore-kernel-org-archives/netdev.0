From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Tue, 16 Feb 2016 12:26:08 -0800
Message-ID: <56C385E0.2000405@cumulusnetworks.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com> <1454700472-13543-2-git-send-email-rshearma@brocade.com> <20160216.104115.1576720778383292937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35081 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755984AbcBPU0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:26:10 -0500
Received: by mail-pa0-f46.google.com with SMTP id ho8so110440033pac.2
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:26:10 -0800 (PST)
In-Reply-To: <20160216.104115.1576720778383292937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/16, 7:41 AM, David Miller wrote:
> Statistics not provided via netlink are useless in real installations.
>
> In fact I would say to forego the proc interface entirely, it's a second
> class citizen for statistics gathering and has a non-triviel per-device
> cost for instantiation.
>
+1

I agree with the cost too.

Robert, I was thinking of responding to your series to add netlink stats for AF_MPLS in
 rtnl_af_ops (similar to  IFLA_INET6_STATS). But, soon realized that it is currently used by ipv6 alone
and it also ended up with a skip filter (RTEXT_FILTER_SKIP_STATS). So, extending that interface for
mpls is not the right thing to do either.

There is work being done for a separate netlink infrastructure for stats.
I would wait for that infrastructure to be ready to add mpls stats. It should be available soon.

thanks,
Roopa
