From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 2/3] RDS: TCP: Retransmit half-sent datagrams when
 switching sockets in rds_tcp_reset_callbacks
Date: Mon, 6 Jun 2016 12:05:04 -0700
Message-ID: <42f23427-74f8-d629-6b6b-9c66462bce1e@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
 <8a0f92e2ba01c13011156aa1a6fe9d25e1184f7e.1465071319.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35644 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbcFFTFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:05:16 -0400
In-Reply-To: <8a0f92e2ba01c13011156aa1a6fe9d25e1184f7e.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2016 1:59 PM, Sowmini Varadhan wrote:
> When we switch a connection's sockets in rds_tcp_rest_callbacks,
> any partially sent datagram must be retransmitted on the new
> socket so that the receiver can correctly reassmble the RDS
> datagram. Use rds_send_reset() which is designed for this purpose.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
