From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][UNIX] Move the unix sock iterators in to proper place
Date: Fri, 23 Nov 2007 20:30:36 +0800
Message-ID: <20071123123036.GD18862@gondor.apana.org.au>
References: <47458296.60908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3464 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752209AbXKWMaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 07:30:52 -0500
Content-Disposition: inline
In-Reply-To: <47458296.60908@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 04:22:30PM +0300, Pavel Emelyanov wrote:
> The first_unix_socket() and next_unix_sockets() are now used
> in proc file and in forall_unix_socets macro only.
> 
> The forall_unix_sockets is not used in this file at all so
> remove it. After this move the helpers to where they really 
> belong, i.e. closer to proc code under the #ifdef CONFIG_PROC_FS
> option.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Patch applied.  Thanks Pavel!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
