From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Tue, 21 Jun 2016 13:50:53 +0300
Message-ID: <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com>
 <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com> <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33572 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbcFULNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 07:13:05 -0400
Received: by mail-ob0-f172.google.com with SMTP id xn17so17165153obc.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 04:12:53 -0700 (PDT)
In-Reply-To: <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-06-20 17:11 GMT+03:00 zhuyj <zyjzyj2000@gmail.com>:
> 5. Switch Configuration
> =======================
>
>         For this section, "switch" refers to whatever system the
> bonded devices are directly connected to (i.e., where the other end of
> the cable plugs into).  This may be an actual dedicated switch device,
> or it may be another regular system (e.g., another computer running
> Linux),
>
>         The active-backup, balance-tlb and balance-alb modes do not
> require any specific configuration of the switch.
>
>         The 802.3ad mode requires that the switch have the appropriate
> ports configured as an 802.3ad aggregation.  The precise method used
> to configure this varies from switch to switch, but, for example, a
> Cisco 3550 series switch requires that the appropriate ports first be
> grouped together in a single etherchannel instance, then that
> etherchannel is set to mode "lacp" to enable 802.3ad (instead of
> standard EtherChannel).

The ports are configured in switch settings (HP Procurve 2530-48G) in
same trunk group (TrkX) and trunk group type is set as LACP.
/proc/net/bonding/bond0 also shows that the three ports belong to same
aggregator and bandwidth tests also support this. In my understanding
Procurve's trunk group is pretty much the same as etherchannel in
Cisco's terminology. The bonded link comes always up properly, but
handling of links going down is the problem. Are there known
differences between different vendors there?

Veli-Matti
