From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v02: Enforcement for SELinux
Date: Mon, 18 Sep 2006 14:37:42 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181436180.5976@d.namei>
References: <45019F72.2050708@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:32666 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750957AbWIRSho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:37:44 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F72.2050708@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> +	if (selinux_compat_net) {
> +		err = selinux_xfrm_decode_session(skb, &peersid, 0);
> +		BUG_ON(err);

I'm pretty sure this should not be a BUG_ON.  IIUC, you want to panic the 
kernel because one of the nested SAs has a different security context.

> +	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
> +	BUG_ON(err);

Same.


-- 
James Morris
<jmorris@namei.org>
