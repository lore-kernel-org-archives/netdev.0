From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [iproute PATCH v3 3/5] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Wed, 25 Nov 2015 16:36:04 +0300
Message-ID: <5655B944.8030903@cogentembedded.com>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
 <1448375464-12145-4-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33022 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbbKYNgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 08:36:07 -0500
Received: by lfaz4 with SMTP id z4so60610279lfa.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 05:36:06 -0800 (PST)
In-Reply-To: <1448375464-12145-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/24/2015 5:31 PM, Phil Sutter wrote:

> Linux version 3.1 introduced a consistency check for netlink dumps in
> commit 670dc28 ("netlink: advertise incomplete dumps"). This bites

    Need 12-digit SHA1 here, scripts/checkpatch.pl checks this now.

> iproute2 when flushing more addresses than can fit into a single
> RTM_GETADDR response. To silence the spurious error message "Dump was
> interrupted and may be inconsistent.", advise rtnl_dump_filter_l() to
> not care about NLM_F_DUMP_INTR.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
[...]

MBR, Sergei
