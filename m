From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: RE: [PATCH net v3] driver: veth: Fix one possbile memleak when fail to register_netdevice
Date: Tue, 2 May 2017 18:51:24 +0800
Message-ID: <000201d2c332$0c73c320$255b4960$@vip.163.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com> <92eab1fc-cd70-1561-1f94-665e77725750@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <davem@davemloft.net>,
        <jarod@redhat.com>, <lucien.xin@gmail.com>,
        <stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:49808 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdEBK4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 06:56:53 -0400
In-Reply-To: <92eab1fc-cd70-1561-1f94-665e77725750@cumulusnetworks.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Monday, May 1, 2017 11:08 PM
> On 4/28/17 9:51 PM, gfree.wind@foxmail.com wrote:
> > diff --git a/drivers/net/veth.c b/drivers/net/veth.c index
> > 8c39d6d..418376a 100644
> > --- a/drivers/net/veth.c
> > +++ b/drivers/net/veth.c
> > @@ -224,9 +224,21 @@ static int veth_dev_init(struct net_device *dev)
> >  	return 0;
> >  }
> >
> > -static void veth_dev_free(struct net_device *dev)
> > +static void veth_destructor_free(struct net_device *dev)
> 
> _destructor in the name is confusing since veth_dev_free is the
> dev->destructor. Perhaps that should be veth_free_stats.

Because I want to emphasize it should be invoked in the destructor.
What's your opinion ?


[...]
> Functionally, it looks good to me.
> 
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

Thanks David.
I have sent the v4 patches with a series according to David's advice.

BTW, because I send multiple patches too fast today, the email server blocks
my account.
So I have to reply you with a different email account. Sorry.

Regards
Feng
