From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH -next] caif_virtio: fix error return code in
 cfv_create_genpool()
Date: Fri, 22 Mar 2013 15:27:39 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C10579249583EE23@EXDCVYMBSTM005.EQ1STM.local>
References: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
 <20130322.102425.1728735565421860819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"weiyj.lk@gmail.com" <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:36516 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933416Ab3CVO1z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 10:27:55 -0400
In-Reply-To: <20130322.102425.1728735565421860819.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >
> > Fix to return a negative error code from the error handling
> > case instead of 0, as returned elsewhere in this function.
> >
> > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > ---
> >  drivers/net/caif/caif_virtio.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> I can't apply this as this file doesn't exist in my tree.

caif_virtio.c lives in Rusty's "virtio-next" tree. 
I guess this patch should have been tagged "virtio-next" instead.

Thanks,
Sjur
