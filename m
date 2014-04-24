From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Remove useless secid field from xfrm_audit.
Date: Thu, 24 Apr 2014 12:55:05 +0200
Message-ID: <20140424105505.GU32371@secunet.com>
References: <201404190100.IJG17653.VOSHJMtFQFOLOF@I-love.SAKURA.ne.jp>
 <20140422120256.GT32371@secunet.com>
 <201404222148.JCD13571.QLFFJMtHOSFVOO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <jmlatten@linux.vnet.ibm.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53631 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbaDXKzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:55:12 -0400
Content-Disposition: inline
In-Reply-To: <201404222148.JCD13571.QLFFJMtHOSFVOO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2014 at 09:48:30PM +0900, Tetsuo Handa wrote:
> 
> Wow. I raced with your commit. I was making V2 patch because it seemed
> to me that
> 
>   struct xfrm_audit {
>   	u32     secid;
>   	kuid_t  loginuid;
>   	unsigned int sessionid;
>   };
> 
> can be packed as "bool" and replace "kuid_t auid, unsigned int ses, u32 secid"
> arguments with single bool argument.
> 
> I subtracted your commit from my V2 patch. Would you check below one?
> ----------
> >From 225dcb015abbad724cb4b6bda837e0132eb7b2dc Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 22 Apr 2014 21:34:34 +0900
> Subject: [PATCH] xfrm: Remove useless xfrm_audit struct.
> 
> Commit f1370cc4 "xfrm: Remove useless secid field from xfrm_audit." changed
> "struct xfrm_audit" to have either
> { audit_get_loginuid(current) / audit_get_sessionid(current) } or
> { INVALID_UID / -1 } pair.
> 
> This means that we can represent "struct xfrm_audit" as "bool".
> This patch replaces "struct xfrm_audit" argument with "bool".
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Looks good, also applied.

Thanks a lot!
