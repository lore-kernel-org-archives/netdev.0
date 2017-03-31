From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 18/18] net: hns: Some checkpatch.pl script &
 warning fixes
Date: Fri, 31 Mar 2017 16:46:53 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A8E7FB5@lhreml503-mbx>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
         <20170331112032.4692-19-salil.mehta@huawei.com>
 <1490975097.27353.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Joe Perches <joe@perches.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490975097.27353.10.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, March 31, 2017 4:45 PM
> To: Salil Mehta; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 18/18] net: hns: Some checkpatch.pl
> script & warning fixes
> 
> On Fri, 2017-03-31 at 12:20 +0100, Salil Mehta wrote:
> > This patch fixes some checkpatch.pl script caught errors and
> > warnings during the compilation time.
> []
> > diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> []
> > @@ -512,7 +512,8 @@ static void hns_nic_reuse_page(struct sk_buff
> *skb, int i,
> >  	int last_offset;
> >  	bool twobufs;
> >
> > -	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring) ==
> HNS_BUFFER_SIZE_2048);
> > +	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring)
> > +			== HNS_BUFFER_SIZE_2048);
> 
> This would read nicer without splitting a comparison test
> onto multiple lines
> 
> 	twobufs = PAGE_SIZE < 8192 &&
> 		  hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048;
For sure, thanks for noticing. Will correct this!

Best regards
Salil
> 
