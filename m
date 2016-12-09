From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv4: Should use consistent conditional judgement for ip
 fragment in __ip_append_data and ip_finish_output
Date: Fri, 9 Dec 2016 15:03:47 +0300
Message-ID: <6b85952d-a16d-2920-ebde-c69cec7e1494@cogentembedded.com>
References: <1481252918-3514-1-git-send-email-lizheng043@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: james.z.li@ericsson.com
To: Zheng Li <lizheng043@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481252918-3514-1-git-send-email-lizheng043@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/9/2016 6:08 AM, Zheng Li wrote:

> From: zheng li <james.z.li@ericsson.com>
>
> There is an inconsitent conditional judgement in __ip_append_data and

    Inconsistent.

> ip_finish_output functions, the variable length in __ip_append_data just
> include the length of applicatoin's payload and udp header, don't include

    Application.

> the length of ip header, but in ip_finish_output use
> (skb->len > ip_skb_dst_mtu(skb)) as judgement, and skb->len include the
> length of ip header.
>
> That cuase some particular applicatoin's udp payload whose length is

    Causes, application.

> between (MTU - IP Header) and MTU were framented by ip_fragment even

    Fragmented.

> though the rst->dev support UFO feature.
>
> Add the length of ip header to length in __ip_append_data to keep
> consistent conditional judgement as ip_finish_output for ip fragment.
>
> Signed-off-by: Zheng Li <james.z.li@ericsson.com>
[...]

MBR, Sergei
