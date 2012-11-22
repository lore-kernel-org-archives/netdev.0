From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] ipv6: adapt connect for repair move
Date: Thu, 22 Nov 2012 15:51:22 +0400
Message-ID: <50AE11BA.4030803@parallels.com>
References: <1353582838-18876-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353582838-18876-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22/2012 03:13 PM, Andrey Vagin wrote:
> This is work the same as for ipv4.
> 
> All other hacks about tcp repair are in common code for ipv4 and ipv6,
> so this patch is enough for repairing ipv6 connections.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

> ---
>  net/ipv4/tcp_ipv4.c   | 13 +------------
>  net/ipv4/tcp_output.c |  5 +++++
>  net/ipv6/tcp_ipv6.c   |  2 +-
>  3 files changed, 7 insertions(+), 13 deletions(-)
