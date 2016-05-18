From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 2/2] RDS: TCP: Avoid rds connection churn from rogue
 SYNs
Date: Wed, 18 May 2016 11:33:59 -0700
Message-ID: <bac715b0-569b-4017-51fe-7763ba77ca52@oracle.com>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
 <b768a2aabf58f282e8058cf04dfed5d682cf0110.1463579486.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46077 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbcERSeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 14:34:21 -0400
In-Reply-To: <b768a2aabf58f282e8058cf04dfed5d682cf0110.1463579486.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/2016 10:06 AM, Sowmini Varadhan wrote:
> When a rogue SYN is received after the connection arbitration
> algorithm has converged, the incoming SYN should not needlessly
> quiesce the transmit path, and it should not result in needless
> TCP connection resets due to re-execution of the connection
> arbitration logic.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
