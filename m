From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] LSM-IPsec SELinux Authorize
Date: Mon, 5 Jun 2006 18:32:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606051830140.7331@d.namei>
References: <20060605195607.GA28030@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, latten@austin.ibm.com, sergeh@us.ibm.com,
	gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:49327 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750785AbWFEWcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 18:32:13 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060605195607.GA28030@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jun 2006, Catherine Zhang wrote:


Looks ok to me, except for one minor nit:

> +	if (ctx) {
> +		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
> +		SECCLASS_ASSOCIATION,
> +		ASSOCIATION__SETCONTEXT, NULL);
> +	}

you don't need the braces here (similar again further in the patch).


- James
-- 
James Morris
<jmorris@namei.org>
