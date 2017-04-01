From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next 2/2] rds: tcp: canonical connection order for all
 paths with index > 0
Date: Sat, 1 Apr 2017 11:54:02 -0700
Message-ID: <8f4b58aa-8dcd-9431-319d-46a3580b7eef@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
 <dd4baab053150f26c6fff124c4f4c9b417a9eb80.1490814967.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28579 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751931AbdDASyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:54:07 -0400
In-Reply-To: <dd4baab053150f26c6fff124c4f4c9b417a9eb80.1490814967.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/17 3:56 PM, Sowmini Varadhan wrote:
> The rds_connect_worker() has a bug in the check that enforces the
> canonical connection order described in the comments of
> rds_tcp_state_change(). The intention is to make sure that all
> the multipath connections are always initiated by the smaller IP
> address via rds_start_mprds. To achieve this, rds_connection_worker
> should check that cp_index > 0.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
