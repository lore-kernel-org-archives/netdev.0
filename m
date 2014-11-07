From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 4/5] ip link: Add support for remote
 checksum offload
Date: Thu, 6 Nov 2014 16:14:45 -0800
Message-ID: <20141106161445.78bdd512@urahara>
References: <1415210788-8058-1-git-send-email-therbert@google.com>
	<1415210788-8058-5-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:63895 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaKGAO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 19:14:59 -0500
Received: by mail-pd0-f179.google.com with SMTP id g10so2152971pdj.38
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 16:14:58 -0800 (PST)
In-Reply-To: <1415210788-8058-5-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  5 Nov 2014 10:06:27 -0800
Tom Herbert <therbert@google.com> wrote:

> This patch adds support to remote checksum checksum offload
> confinguration for IPIP, SIT, and GRE tunnels. This patch
> adds a [no]encap-remcsum to ip link command which applicable
> when configured tunnels that use GUE.
> 
> http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00
> 
> Example:
> 
> ip link add name tun1 type gre remote 192.168.1.1 local 192.168.1.2 \
>    ttl 225 encap fou encap-sport auto encap-dport 7777 encap-csum \
>    encap-remcsum
> 
> This would create an GRE tunnel in GUE encapsulation where the source
> port is automatically selected (based on hash of inner packet),
> checksums in the encapsulating UDP header are enabled (needed.for
> remote checksum offload), and remote checksum is configured to
> be used on the tunnel (affects TX side).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/if_tunnel.h |  1 +

This patch is for net-next not current release
Remote checksum offload flag does not exist in upstream tree (net or linus).

Please don't mix patches for current and future releases together.
