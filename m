From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/10] [NET]: Avoid unnecessary cloning for ingress
	filtering
Date: Sun, 14 Oct 2007 06:49:51 -0400
Message-ID: <1192358991.4892.23.camel@localhost>
References: <20071014042604.GA11431@gondor.apana.org.au>
	 <E1Igv4p-00030c-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:16915 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368AbXJNKt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 06:49:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1408169wxd
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 03:49:55 -0700 (PDT)
In-Reply-To: <E1Igv4p-00030c-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-14-10 at 12:27 +0800, Herbert Xu wrote:
> [NET]: Avoid unnecessary cloning for ingress filtering
> 
> As it is we always invoke pt_prev before ing_filter, even if there are no
> ingress filters attached.  This can cause unnecessary cloning in pt_prev.
> 
> This patch changes it so that we only invoke pt_prev if there are ingress
> filters attached.
> 

ACK from here this as well as for patch 10/10. Once this patchset makes
it into net-2.6.24 i can do testing on my laptop and provide you any
further feedback. Transiting, so I may loose connectivity RSN but
overall GoodStuff.

cheers,
jamal

