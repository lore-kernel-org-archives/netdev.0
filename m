From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ipmonitor: match user option 'all' before
 'all-nsid'
Date: Wed, 3 Feb 2016 09:20:28 +0100
Message-ID: <56B1B84C.1010606@6wind.com>
References: <1454460820-21851-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36768 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbcBCIUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:20:48 -0500
Received: by mail-wm0-f53.google.com with SMTP id p63so152981805wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 00:20:47 -0800 (PST)
In-Reply-To: <1454460820-21851-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/02/2016 01:53, Roopa Prabhu a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> 'ip monitor all' is broken on older kernels.
> This patch fixes 'ip monitor all' to match
> 'all' and not 'all-nsid'.
>
> It moves parsing arg 'all-nsid' to after parsing
> 'all'.
>
> Before:
> $ip monitor all
> NETLINK_LISTEN_ALL_NSID: Protocol not available
>
> After:
> $ip monitor all
> [NEIGH]Deleted 10.0.0.1 dev eth1 lladdr c4:54:44:4f:b2:dd STALE
>
> Fixes: 449b824ad196 ("ipmonitor: allows to monitor in several netns")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
