From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next 1/2] rds: tcp: allow progress of
 rds_conn_shutdown if the rds_connection is marked ERROR by an intervening FIN
Date: Sat, 1 Apr 2017 11:53:41 -0700
Message-ID: <0ad57c65-246e-195c-f76b-6afbb5b9c25e@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
 <4b20bf8cbe541a263b12eb54b2e504e33b8a6a52.1490814967.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31134 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdDASxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:53:53 -0400
In-Reply-To: <4b20bf8cbe541a263b12eb54b2e504e33b8a6a52.1490814967.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/17 3:56 PM, Sowmini Varadhan wrote:
> rds_conn_shutdown() runs in workq context, and marks the rds_connection
> as DISCONNECTING before quiescing Tx/Rx paths. However, after all I/O
> has quiesced, we may still find the rds_connection state to be
> RDS_CONN_ERROR if an intervening FIN was processed in softirq context.
>
> This is not a fatal error: rds_conn_shutdown() should continue the
> shutdown, and there is no need to log noisy messages about this event.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
