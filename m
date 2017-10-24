From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] rds: Fix uninitialized variable
Date: Tue, 24 Oct 2017 08:46:53 -0700
Message-ID: <25f82b2b-e304-67a0-c840-94abe217e1dc@oracle.com>
References: <20171024150227.15912-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024150227.15912-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

$subject
s/rds:/rds: ib:

On 10/24/2017 8:02 AM, Håkon Bugge wrote:
> send_flags needs to be initialized before calling
> rds_ib_set_wr_signal_state().
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> ---
Looks fine otherwise. Please re-post with subject fixed.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
