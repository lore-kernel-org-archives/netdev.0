From: Rusty Russell <rusty@rustcorp.com.au>
Subject: RE: [PATCH -next] caif_virtio: fix error return code in cfv_create_genpool()
Date: Mon, 25 Mar 2013 20:43:19 +1030
Message-ID: <87txnzdby8.fsf@rustcorp.com.au>
References: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com> <20130322.102425.1728735565421860819.davem@davemloft.net> <81C3A93C17462B4BBD7E272753C10579249583EE23@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "yongjun_wei\@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Sjur BRENDELAND <sjur.brandeland@stericsson.com>,
	David Miller <davem@davemloft.net>,
	"weiyj.lk\@gmail.com" <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43628 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951Ab3CYXAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 19:00:23 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C10579249583EE23@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sjur BRENDELAND <sjur.brandeland@stericsson.com> writes:

>> From: David Miller [mailto:davem@davemloft.net]
>> > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> >
>> > Fix to return a negative error code from the error handling
>> > case instead of 0, as returned elsewhere in this function.
>> >
>> > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> > ---
>> >  drivers/net/caif/caif_virtio.c | 4 +++-
>> >  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> I can't apply this as this file doesn't exist in my tree.
>
> caif_virtio.c lives in Rusty's "virtio-next" tree. 
> I guess this patch should have been tagged "virtio-next" instead.

Thanks, I've applied this.

Cheers,
Rusty.
