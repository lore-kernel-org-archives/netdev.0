From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ipv6 possible opt panic in ip6_append_data()
Date: Wed, 24 Mar 2004 14:07:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040324140725.1c45cc58.davem@redhat.com>
References: <20040310144758.5e0b4c7c.davem@redhat.com>
	<Pine.LNX.4.44.0403241114130.16922-100000@DYN318430BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0403241114130.16922-100000@DYN318430BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Mar 2004 11:20:06 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> [Old subject: Re: [PATCH AND RFC_PATCH] 1. Leak corking option in ipv4 2.
> ipv6 opt panic]
 ...
> Following patch implements what you suggested.
 ...
> +			} else if (np->cork.opt->tot_len < opt->tot_len) {
> +				printk(KERN_DEBUG "ip6_append_data: invalid option length\n");
> +				return -EINVAL;
>  			}

Perfect, thanks for following up on this Krishna.

Patch applied.
