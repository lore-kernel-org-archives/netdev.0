From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] uapi: fix linux/rds.h userspace compilation
 error
Date: Sun, 19 Feb 2017 18:16:35 -0500 (EST)
Message-ID: <20170219.181635.888171103093220298.davem@davemloft.net>
References: <20170215200946.GI1028@altlinux.org>
        <20170216150545.GE13804@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216150545.GE13804@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 16 Feb 2017 18:05:45 +0300

> On the kernel side, sockaddr_storage is #define'd to
> __kernel_sockaddr_storage.  Replacing struct sockaddr_storage with
> struct __kernel_sockaddr_storage defined by <linux/socket.h> fixes
> the following linux/rds.h userspace compilation error:
> 
> /usr/include/linux/rds.h:226:26: error: field 'dest_addr' has incomplete type
>   struct sockaddr_storage dest_addr;
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
