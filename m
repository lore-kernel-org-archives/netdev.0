From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13097] New: Kernel will freeze network after
	using a tun/tap device
Date: Fri, 17 Apr 2009 08:58:42 +0800
Message-ID: <20090417005842.GA30556@gondor.apana.org.au>
References: <20090415152946.90bbdfc0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, maxk@qualcomm.com, vtun@office.satix.net,
	aabdulla@nvidia.com, bugzilla-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55038 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752626AbZDQA6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 20:58:47 -0400
Content-Disposition: inline
In-Reply-To: <20090415152946.90bbdfc0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> With 2.6.29 kernel everything works fine, but with 2.6.30-rc2, a simple ping to
>> a tun/tap device (for example ping to a vpn using openvpn) will freeze the
>> network. In X I can't even use the keyboard anymore.
>> 
>> It just happens with a tun/tap device, not with a normal ethernet device or a
>> normal internet connection.
>> 
>> If you think it's a tun/tap driver problem, please change the bug, but as I'm
>> not completely sure, I choose forcedeth.
> 
> An obvious question would be: are you able to test the same setup with
> a different type of network card?

Please get a stack backtrace of all processes on the machine after
the hang, e.g., with Ctrl-ScrollLock.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
