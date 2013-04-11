From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2 v2] vxlan: Allow setting destination to unicast
 address.
Date: Thu, 11 Apr 2013 18:48:20 +0100
Message-ID: <1365702500.7355.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <87li8pmkvh.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49026 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934868Ab3DKRs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:48:27 -0400
In-Reply-To: <87li8pmkvh.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 19:17 +0900, Atzm Watanabe wrote:
> This patch allows setting VXLAN destination to unicast address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
> 
> v2: use a new argument "remote" instead of "group" based by
>     Stephen Hemminger's comments.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
[...]
> --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -23,7 +23,8 @@
>  
>  static void explain(void)
>  {
> -	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
> +	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ remote ADDR ]\n");
[...]

Shouldn't that be "[ group|remote ADDR ]", to show that you can specify
one or the other?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
