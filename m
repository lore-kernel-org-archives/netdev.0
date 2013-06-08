From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: add missing
 /proc/sys/net/ipv6/ping_group_range
Date: Sat, 08 Jun 2013 20:05:35 +0800
Message-ID: <1370693135.868.6.camel@cr0>
References: <1370685275-22059-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab3FHMFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 08:05:45 -0400
In-Reply-To: <1370685275-22059-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-08 at 17:54 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> commit 6d0bfe22611602f366 (net: ipv6: Add IPv6 support to the ping socket.)
> adds IPv6 ping socket support, but forgot to create
> /proc/sys/net/ipv6/ping_group_range, therefore it wrongly shares
> /proc/sys/net/ipv4/ping_group_range with IPv4.
> 

Hmm, this might not be a problem, I just noticed there are other
sysctl's (for example ip_early_demux) shared by IPv4 and IPv6.
