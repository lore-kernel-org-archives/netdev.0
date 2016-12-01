From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS: TCP: unregister_netdevice_notifier() in error
 path of rds_tcp_init_net
Date: Thu, 1 Dec 2016 08:40:04 -0800
Message-ID: <8ef28282-1b55-b123-e8a9-43a21aca0ba6@oracle.com>
References: <1480596283-204869-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51177 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760466AbcLAQjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:39:54 -0500
In-Reply-To: <1480596283-204869-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/2016 4:44 AM, Sowmini Varadhan wrote:
> If some error is encountered in rds_tcp_init_net, make sure to
> unregister_netdevice_notifier(), else we could trigger a panic
> later on, when the modprobe from a netns fails.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
