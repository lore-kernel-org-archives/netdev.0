From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next 3/5] RDS: TCP: Enable multipath RDS for TCP
Date: Thu, 14 Jul 2016 09:47:46 -0700
Message-ID: <a06d31cc-bc19-476a-1c68-b396d0cb8f09@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
 <7a00f744a33192a5126b30419f7526795ab77cae.1468488884.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49470 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbcGNQrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 12:47:49 -0400
In-Reply-To: <7a00f744a33192a5126b30419f7526795ab77cae.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/2016 3:51 AM, Sowmini Varadhan wrote:
> Use RDS probe-ping to compute how many paths may be used with
> the peer, and to synchronously start the multiple paths. If mprds is
> supported, hash outgoing traffic to one of multiple paths in rds_sendmsg()
> when multipath RDS is supported by the transport.
>
> CC: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Thanks for updating the earlier version discussed off-list.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
