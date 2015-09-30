From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next 3/3] RDS-TCP: Set up MSG_MORE and
 MSG_SENDPAGE_NOTLAST as appropriate in rds_tcp_xmit
Date: Wed, 30 Sep 2015 08:56:34 -0700
Message-ID: <560C0632.5060108@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
 <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/30/2015 6:45 AM, Sowmini Varadhan wrote:
> For the same reasons as 2f53384424 and 35f9c09fe9, rds_tcp_xmit
> may have multiple pages to send, so use the MSG_MORE and
> MSG_SENDPAGE_NOTLAST as hints to tcp_sendpage()
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Your checkpatch.pl should have complained about commit
reference in the change-log. You might want to fix that
for consistency.

Patch itself is fine.
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
