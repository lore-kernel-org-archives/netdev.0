From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 1/3] ipv6: Select fragment id during UFO
	segmentation if not set.
Date: Tue, 03 Feb 2015 23:08:18 -0800 (PST)
Message-ID: <20150203.230818.984435325973223729.davem@davemloft.net>
References: <1422999377-18777-1-git-send-email-vyasevic@redhat.com>
	<1422999377-18777-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: vyasevich@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422999377-18777-2-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue,  3 Feb 2015 16:36:15 -0500

> diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
> index 97f41a3..54520a0 100644
> --- a/net/ipv6/output_core.c
> +++ b/net/ipv6/output_core.c
> @@ -9,6 +9,24 @@
>  #include <net/addrconf.h>
>  #include <net/secure_seq.h>
>  
> +u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst, struct in6_addr *src)

__ipv6_select_ident() is not used anywhere outside of this file, please
mark it static and remove the declaration for it from net/ipv6.h
