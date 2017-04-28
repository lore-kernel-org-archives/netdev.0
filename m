From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net] driver/net: Fix possible memleaks when fail to register_netdevice
Date: Fri, 28 Apr 2017 08:27:45 +0800
Message-ID: <000701d2bfb6$425dead0$c719c070$@foxmail.com>
References: <1493121710-27910-1-git-send-email-gfree.wind@foxmail.com> <20170427081559.GA1058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jiri@resnulli.us>, <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>,
        "'Gao Feng'" <fgao@ikuai8.com>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:46957 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030294AbdD1A1z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 20:27:55 -0400
In-Reply-To: 
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Gao Feng [mailto:gfree.wind@foxmail.com]
> Sent: Thursday, April 27, 2017 4:33 PM
> > From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> > Sent: Thursday, April 27, 2017 4:16 PM On Tue, Apr 25, 2017 at
> > 08:01:50PM +0800, gfree.wind@foxmail.com wrote:
> > > From: Gao Feng <fgao@ikuai8.com>
> > >
> [...]
> >
[...]

I think I get one method which could be safe to free the mem in ndo_uninit.
Thanks, I would send the v2 patch later.

Best Regards
Feng
