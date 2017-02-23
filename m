From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] uapi: fix linux/rds.h userspace compilation errors
Date: Wed, 22 Feb 2017 17:40:04 -0800
Message-ID: <d10362cd-8102-d9a4-d3b2-0bccd9df9026@oracle.com>
References: <20170223011320.GA16142@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Dmitry V. Levin" <ldv@altlinux.org>,
        "David S. Miller" <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223011320.GA16142@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/2017 5:13 PM, Dmitry V. Levin wrote:
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
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> ---
This was part of the patch I submitted other-day with
rest of the clean-up. Thanks Dmitry.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
