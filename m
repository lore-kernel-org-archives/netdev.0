From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/seg6.h and linux/seg6_iptunnel.h
 userspace compilation errors
Date: Thu, 23 Feb 2017 10:55:36 -0500 (EST)
Message-ID: <20170223.105536.682859548926458106.davem@davemloft.net>
References: <20170223011355.GB16142@altlinux.org>
        <20170223113034.GA22568@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.lebrun@uclouvain.be, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223113034.GA22568@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 23 Feb 2017 14:30:34 +0300

> Include <linux/in6.h> in uapi/linux/seg6.h to fix the following
> linux/seg6.h userspace compilation error:
> 
> /usr/include/linux/seg6.h:31:18: error: array type has incomplete element type 'struct in6_addr'
>   struct in6_addr segments[0];
> 
> Include <linux/seg6.h> in uapi/linux/seg6_iptunnel.h to fix
> the following linux/seg6_iptunnel.h userspace compilation error:
> 
> /usr/include/linux/seg6_iptunnel.h:26:21: error: array type has incomplete element type 'struct ipv6_sr_hdr'
>   struct ipv6_sr_hdr srh[0];
> 
> Fixes: a50a05f497a2 ("ipv6: sr: add missing Kbuild export for header files")
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> ---
> v2: fixed "Fixes:" line

Applied.
