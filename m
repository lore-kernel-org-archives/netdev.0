From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 13:27:04 -0700
Message-ID: <5717E618.5090406@cumulusnetworks.com>
References: <1461167023-7640-1-git-send-email-roopa@cumulusnetworks.com> <20160420.160849.1254968687102415877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34198 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcDTU1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:27:06 -0400
Received: by mail-pf0-f176.google.com with SMTP id y69so5434233pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 13:27:06 -0700 (PDT)
In-Reply-To: <20160420.160849.1254968687102415877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/16, 1:08 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Wed, 20 Apr 2016 08:43:43 -0700
>
>> This patch adds a new RTM_GETSTATS message to query link stats via netlink
>> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases when
>> frequent polling for stats from userspace is a common operation.
> With nla_align_64bit() now working properly, I've applied this and it works
> on sparc64 too.
>
> Thanks!
Thank you.
