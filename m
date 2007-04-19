From: Bartek <poemann@gmail.com>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Thu, 19 Apr 2007 10:49:16 +0200
Message-ID: <19061b0b0704190149j5057a89drb48664bb48110dd3@mail.gmail.com>
References: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
	 <E1HeHoZ-0000Y6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Paul Mackerras" <paulus@samba.org>, davem@davemloft.net,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:15998 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161305AbXDSItQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 04:49:16 -0400
Received: by wr-out-0506.google.com with SMTP id 76so531808wra
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2007 01:49:16 -0700 (PDT)
In-Reply-To: <E1HeHoZ-0000Y6-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Your fix is probably needed too.  However, I think the issue that Patrick
> was trying to fix is the case where p[0] != PPP_ALLSTATIONS and therefore
> we'd still have a problem there.

I tested Paul's patch for last few days and I think everything seems
ok. The system is stable.

Regards
Bartek
