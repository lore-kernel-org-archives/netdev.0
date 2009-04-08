From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] IPv4/IPv6: update sysctl files
Date: Tue, 07 Apr 2009 19:41:10 -0700
Message-ID: <m11vs3rho9.fsf@fess.ebiederm.org>
References: <49DC091C.6070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shen Feng <shen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49333 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZDHClP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 22:41:15 -0400
In-Reply-To: <49DC091C.6070708@cn.fujitsu.com> (Shen Feng's message of "Wed\, 08 Apr 2009 10\:17\:00 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shen Feng <shen@cn.fujitsu.com> writes:

> Now the following sysctl files in /proc/sys/net/ipv4 are used by
> both IPv4 and IPv6.
> tcp_mem  tcp_rmem  tcp_wmem
> udp_mem  udp_rmem_min  udp_wmem_min
> Putting them in /proc/sys/net/ipv4 is not a good choice.
>
> So move tcp_mem  tcp_rmem  tcp_wmem to /proc/sys/net/tcp and
> move udp_mem  udp_rmem_min  udp_wmem_min to /poc/sys/net/udp.

How badly does this blow up when you enable sysctl_check?
You just enabled new binary sysctl mappings, which is big no-no.

Further how many user space scripts did you break that touch those
files?  This is an ABI change.

Eric
