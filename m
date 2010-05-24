From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Mon, 24 May 2010 21:24:38 +1000
Message-ID: <20100524112438.GA29848@gondor.apana.org.au>
References: <20100523.234441.66200781.davem@davemloft.net> <20100523.235557.165343768.davem@davemloft.net> <20100524070743.GA26871@gondor.apana.org.au> <20100524.001429.259990428.davem@davemloft.net> <20100524110950.GA22216@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51144 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756874Ab0EXLYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 07:24:55 -0400
Content-Disposition: inline
In-Reply-To: <20100524110950.GA22216@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 24, 2010 at 07:09:50AM -0400, Neil Horman wrote:
>
> Excuse all my noise from before, Herberts patch works fine.  Apparently the
> problem was mine.  QEMU creates several threads during startup, but adding the
> processid to a cgroup doesn't cause its child threads to get added
> automatically.  Doing this by hand causes this to work.

Thanks a lot for testing Neil!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
