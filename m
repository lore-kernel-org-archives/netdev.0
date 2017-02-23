From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] uapi: fix linux/rds.h userspace compilation errors
Date: Thu, 23 Feb 2017 14:20:24 +0300
Message-ID: <46a28c0c-36fe-db81-d263-f737f1d3ea05@cogentembedded.com>
References: <20170223011320.GA16142@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Dmitry V. Levin" <ldv@altlinux.org>,
        "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223011320.GA16142@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 2/23/2017 4:13 AM, Dmitry V. Levin wrote:

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
> Fixes: 3289025a("RDS: add receive message trace used by application")

    Need at least 12 hex digits and a space before (.

> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
[...]

MBR, Sergei
