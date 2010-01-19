From: Li Yewang <lyw@cn.fujitsu.com>
Subject: Re: [PATCH][XFRM] Use the simple  name when adding SAD with ip	xfrm
 state
Date: Tue, 19 Jan 2010 16:25:22 +0800
Message-ID: <4B556C72.40403@cn.fujitsu.com>
References: <20100119022033.GA18155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49862 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab0ASI03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 03:26:29 -0500
In-Reply-To: <20100119022033.GA18155@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Herbert Xu wrote:
> Li Yewang <lyw@cn.fujitsu.com> wrote:
>> The encryption name such as "rfc3686(ctr(aes))" is too complex.
>> I think simple name is better for user when using "ip xfrm state ..." command.
>>
>>
>> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
> 
> Nack.  If we want to support simple names such as these, they
> should be done in the crypto layer.  Otherwise every crypto user
> that wants this would have to reinvent it.

  But user sets SAD for ipsec with "ip xfrm state ..." must use the name such as "rfc3686(ctr(aes))".
  Is that reasonable? Maybe user can not remember this complex name.

  There are some simple names for other encryptions, 
  such as "cbc(blowfish)", you can use "ip xfrm state ... enc blowfish ...".


