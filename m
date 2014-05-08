From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next 0/2] sctp: fix kfree static array pointer in
 sctp_sysctl_net_unregister
Date: Thu, 8 May 2014 09:45:04 -0400
Message-ID: <20140508134504.GF9696@hmsreliant.think-freely.org>
References: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, dborkman@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56649 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaEHNpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 09:45:17 -0400
Content-Disposition: inline
In-Reply-To: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 08, 2014 at 08:55:00PM +0800, Wang Weidong wrote:
> patch #1 revert the efb842c45("sctp: optimize the sctp_sysctl_net_register")
> patch #2 add a checking for sctp_sysctl_net_register
> 
> Wang Weidong (2):
>   Revert "sctp: optimize the sctp_sysctl_net_register"
>   sctp: add a checking for sctp_sysctl_net_register
> 
>  net/sctp/sysctl.c | 21 +++++++++++----------
>  1 file changed, 11 insertions(+), 10 deletions(-)
> 
> -- 
> 1.7.12
> 
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
