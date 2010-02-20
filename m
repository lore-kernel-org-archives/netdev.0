From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 0/3] net: reserve ports for applications using
 fixed port numbers
Date: Sat, 20 Feb 2010 16:11:40 +0800
Message-ID: <4B7F993C.9000007@redhat.com>
References: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
> allows users to reserve ports for third-party applications.
> 
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.
> 
> Changes from the previous version:
> - switch the /proc entry format to coma separated list of range ports
> - treat -EFAULT just like any other error and acknowledge written values
> - use isdigit() in proc_get_ulong
> 
> Octavian Purdila (3):
>   sysctl: refactor integer handling proc code
>   sysctl: add proc_do_large_bitmap
>   net: reserve ports for applications using fixed port numbers

Hi,

This version looks fine for me, but I need to give them a test, and
I will put feedbacks asap. Thanks for your work!

Still two things:

1) bitops are always atomic on every arch, right? If yes, then ok.
2) I hope you could add some documentation to show the relations
    between ip_local_port_range and ip_local_reserved_ports.

Thanks!
