From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE2 0/2] Add ECN support to tc-netem
Date: Thu, 17 May 2012 14:54:31 -0700
Message-ID: <20120517145431.6d3bb685@nehalam.linuxnetplumber.net>
References: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39526 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762291Ab2EQVyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 17:54:41 -0400
In-Reply-To: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 May 2012 16:51:56 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> Recent patch to net-next kernel from Eric Dumazet (e4ae004b84b netem: add ECN
> capability) made it possible for netem to mark packets with ECN instead of
> dropping them. These two patches add support to iproute2/tc and update the
> manpage.
> 
> Vijay Subramanian (2):
>   Update tc-netem manpage to add ecn capability
>   tc-netem: Add support for ECN packet marking
> 
>  include/linux/pkt_sched.h |    1 +
>  man/man8/tc-netem.8       |    8 ++++++--
>  tc/q_netem.c              |   25 +++++++++++++++++++++++++
>  3 files changed, 32 insertions(+), 2 deletions(-)
> 


I am holding these until 3.5 merge window, since they depend
on the feature still in net-next
