From: David Decotigny <decot@google.com>
Subject: Re: [PATCH] forcedeth: new ethtool stat "tx_timeout" to account for tx_timeouts
Date: Wed, 18 May 2011 14:20:21 -0700
Message-ID: <BANLkTimNvuB5HtOKfAc7rf5wF2QeC3xdXw@mail.gmail.com>
References: <1305752945-14843-1-git-send-email-decot@google.com>
 <1305752945-14843-2-git-send-email-decot@google.com> <20110518.171416.1780927258138770742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe@perches.com>, szymon@janc.net.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-net-upstream@google.com, snanda@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:44231 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab1ERVUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 17:20:43 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p4ILKgXU028278
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:20:43 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by kpbe15.cbf.corp.google.com with ESMTP id p4ILKfUg027430
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:20:41 -0700
Received: by qwb7 with SMTP id 7so1211944qwb.26
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:20:41 -0700 (PDT)
In-Reply-To: <20110518.171416.1780927258138770742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

They should be independent and applicable in any order, except for the
two 'PATCH x/2' which have to go together.

FYI, here is the order in which I'm applying them:
1/ forcedeth: Improve stats counters
2/ forcedeth: new ethtool stat "tx_timeout" to account for tx_timeouts
3/ [PATCH 1/2] forcedeth: make module parameters readable in /sys/module
4/ [PATCH 2/2] forcedeth: allow to silence tx_timeout debug messages
5/ forcedeth: Acknowledge only interrupts that are being processed
6/ forcedeth: Add messages to indicate using MSI or MSI-X
7/ forcedeth: Fix a race during rmmod of forcedeth

Sorry for that.
Regards,

--
David Decotigny



On Wed, May 18, 2011 at 2:14 PM, David Miller <davem@davemloft.net> wrote:
>
> When submitting multiple patches in a patch set, NUMBER THEM.
>
> Otherwise there is no unambiguous way to figure out what order
> I should apply these patches.
>
