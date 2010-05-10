From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch v10 0/3] net: reserve ports for applications using fixed
 port numbers
Date: Mon, 10 May 2010 12:01:33 +0800
Message-ID: <4BE7851D.2090304@redhat.com>
References: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>, ebiederm@xmission.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, xiaosuo@gmail.com,
	adobriyan@gmail.com, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab0EJD54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 23:57:56 -0400
In-Reply-To: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Adding Andrew into Cc, hope can hear from him.)

On 05/05/10 18:26, Amerigo Wang wrote:
> Changes from the previous version:
> - Use 'true' and 'false' for bool's;
> - Fix some coding style problems;
> - Allow appending lines to bitmap proc file so that it will be
>    easier to add new bits.
>
> ------------------>
>
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
> allows users to reserve ports for third-party applications.
>
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.
>
> There are still some miss behaviors with regard to proc parsing in odd
> invalid cases (for "40000\0-40001" all is acknowledged but only 40000
> is accepted) but they are not easy to fix without changing the current
> "acknowledge how much we accepted" behavior.
>
> Because of that and because the same issues are present in the
> existing proc_dointvec code as well I don't think its worth holding
> the actual feature (port reservation) after such petty error recovery
> issues.
>
>

