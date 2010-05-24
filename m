From: David Miller <davem@davemloft.net>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Mon, 24 May 2010 00:14:29 -0700 (PDT)
Message-ID: <20100524.001429.259990428.davem@davemloft.net>
References: <20100523.234441.66200781.davem@davemloft.net>
	<20100523.235557.165343768.davem@davemloft.net>
	<20100524070743.GA26871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755808Ab0EXHOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 03:14:20 -0400
In-Reply-To: <20100524070743.GA26871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 24 May 2010 17:07:43 +1000

> On Sun, May 23, 2010 at 11:55:57PM -0700, David Miller wrote:
>>
>> Probably you only tested the build with cgroups enabled?
> 
> Indeed, that does seem to be the problem here.  It turns out
> that their struct is only declared when CONFIG_CGROUPS is defined,
> how annoying.
> 
> Oh well I guess I'll follow their example :)
> 
> cls_cgroup: Store classid in struct sock

Thanks for fixing this up, applied.
