From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] uapi: fix linux/seg6.h and linux/seg6_iptunnel.h
 userspace compilation errors
Date: Thu, 23 Feb 2017 14:57:40 +0300
Message-ID: <12c26b3a-ba1d-ba4f-8c1d-f9b157fe75ba@cogentembedded.com>
References: <20170223011355.GB16142@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Dmitry V. Levin" <ldv@altlinux.org>,
        "David S. Miller" <davem@davemloft.net>,
        David Lebrun <david.lebrun@uclouvain.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223011355.GB16142@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/23/2017 4:13 AM, Dmitry V. Levin wrote:

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
> Fixes: a50a05f4("ipv6: sr: add missing Kbuild export for header files")

    12 digits and space before ( as well.

> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
[...]

MBR, Sergei
