From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/rds.h userspace compilation errors
Date: Thu, 23 Feb 2017 10:55:43 -0500 (EST)
Message-ID: <20170223.105543.1699699059008041623.davem@davemloft.net>
References: <20170223011320.GA16142@altlinux.org>
        <46a28c0c-36fe-db81-d263-f737f1d3ea05@cogentembedded.com>
        <20170223113523.GB22568@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, sowmini.varadhan@oracle.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223113523.GB22568@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 23 Feb 2017 14:35:23 +0300

> Consistently use types from linux/types.h to fix the following
> linux/rds.h userspace compilation errors:
> 
> /usr/include/linux/rds.h:198:2: error: unknown type name 'u8'
>   u8 rx_traces;
> /usr/include/linux/rds.h:199:2: error: unknown type name 'u8'
>   u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
> /usr/include/linux/rds.h:203:2: error: unknown type name 'u8'
>   u8 rx_traces;
> /usr/include/linux/rds.h:204:2: error: unknown type name 'u8'
>   u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
> /usr/include/linux/rds.h:205:2: error: unknown type name 'u64'
>   u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
> 
> Fixes: 3289025aedc0 ("RDS: add receive message trace used by application")
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
> v2: fixed "Fixes:" line

Applied.
