From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 14:11:28 -0700
Message-ID: <57154D80.9080601@cumulusnetworks.com>
References: <1460957735-44337-1-git-send-email-roopa@cumulusnetworks.com> <20160418.122807.412860510045727785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33322 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbcDRVLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 17:11:30 -0400
Received: by mail-pf0-f175.google.com with SMTP id 184so84926116pff.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 14:11:30 -0700 (PDT)
In-Reply-To: <20160418.122807.412860510045727785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16, 9:28 AM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Sun, 17 Apr 2016 22:35:35 -0700
>
>> This patch adds a new RTM_GETSTATS message to query link stats via n=
etlink
>> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases wh=
en
>> frequent polling for stats from userspace is a common operation.
> The following build failure needs to be resolved:
>
> security/selinux/nlmsgtab.c: In function =A1selinux_nlmsg_lookup=A2:
> include/linux/compiler.h:506:38: error: call to =A1__compiletime_asse=
rt_158=A2 declared with attribute error: BUILD_BUG_ON failed: RTM_MAX !=
=3D (RTM_NEWNSID + 3)
sorry, did not know about this check. sent v5 just now..
