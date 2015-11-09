From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [iproute PATCH v2 4/6] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Mon, 9 Nov 2015 21:51:34 +0300
Message-ID: <5640EB36.306@cogentembedded.com>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-5-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34131 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbbKISvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 13:51:39 -0500
Received: by lffu14 with SMTP id u14so15474675lff.1
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 10:51:38 -0800 (PST)
In-Reply-To: <1447014141-3565-5-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/08/2015 11:22 PM, Phil Sutter wrote:

> Linux version 3.1 introduced a consistency check for netlink dumps in
> commit 670dc28 ("netlink: advertise incomplete dumps"). This bites

    The scripts/checkpatch.pl now enforces 12-digit commit ID...

> iproute2 when flushing more addresses than can fit into a single
> RTM_GETADDR response. To silence the spurious error message "Dump was
> interrupted and may be inconsistent.", advise rtnl_dump_filter_l() to
> not care about NLM_F_DUMP_INTR.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

MBR, Sergei
