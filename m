From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 3/3] net: reserve ports for applications using
 fixed port numbers
Date: Sun, 21 Feb 2010 14:38:19 +0800
Message-ID: <4B80D4DB.6040204@redhat.com>
References: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com> <1266532210-11536-3-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335Ab0BUGe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 01:34:59 -0500
In-Reply-To: <1266532210-11536-3-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
> allows users to reserve ports for third-party applications.
> 
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>


My test case shows this works as expect, I mean reserving local ports.
So, for this one,

Acked-by: WANG Cong <amwang@redhat.com>

Thanks for your work!
