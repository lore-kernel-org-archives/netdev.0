From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] RDS: fix rds-ping deadlock over TCP transport
Date: Sat, 17 Oct 2015 07:33:01 -0400
Message-ID: <562231ED.40403@oracle.com>
References: <1445048001-1086-1-git-send-email-santosh.shilimkar@oracle.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445048001-1086-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2015 10:13 PM, Santosh Shilimkar wrote:

>
> But because of above recursive lock hang with RDS TCP,
> the send work from rds_send_pong() needs to deferred to
> worker to avoid lock up. Given RDS ping is more of connectivity
> test than performance critical path, its should be ok even
> for transport like IB.
>

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
