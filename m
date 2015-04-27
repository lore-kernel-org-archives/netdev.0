From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix the return code when xfrm_*_register_afinfo
 failed
Date: Mon, 27 Apr 2015 12:38:12 +0200
Message-ID: <20150427103812.GL8928@secunet.com>
References: <1429758413-30896-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47770 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932371AbbD0KiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 06:38:15 -0400
Content-Disposition: inline
In-Reply-To: <1429758413-30896-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 11:06:53AM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> If xfrm_*_register_afinfo failed since xfrm_*_afinfo[afinfo->family] had the
> value, return the -EEXIST, not -ENOBUFS
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Also applied to ipsec-next, thanks!
