From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ip: add the type 'vxlan' in the output of "ip link
 help"
Date: Mon, 17 Dec 2012 08:16:05 -0800
Message-ID: <20121217081605.7e2ed94b@nehalam.linuxnetplumber.net>
References: <1355588468-4964-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355588468-4964-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 16 Dec 2012 00:21:08 +0800
zwu.kernel@gmail.com wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
>   The new type 'vxlan' is added in the output of "ip link help"
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  ip/iplink.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index d73c705..5ff8f85 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -84,7 +84,7 @@ void iplink_usage(void)
>  	if (iplink_have_newlink()) {
>  		fprintf(stderr, "\n");
>  		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
> -		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit }\n");
> +		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan }\n");
>  	}
>  	exit(-1);
>  }

Applied
