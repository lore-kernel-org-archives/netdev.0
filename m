From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next] RDS: rds_conn_lookup() should factor in the
 struct net for a match
Date: Thu, 03 Sep 2015 13:36:57 -0700
Message-ID: <55E8AF69.1080703@oracle.com>
References: <20150903202452.GJ17626@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150903202452.GJ17626@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/3/15 1:24 PM, Sowmini Varadhan wrote:
>
> Only return a conn if the rds_conn_net(conn) matches the struct
> net passed to rds_conn_lookup().
>
> Fixes: 467fa15356ac ("RDS-TCP: Support multiple RDS-TCP listen endpoints,
>         one per netns.")
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
