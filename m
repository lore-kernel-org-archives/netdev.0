From: "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
Subject: Re: Re: [PATCH net-next] pktgen: add ttl option for pktgen
Date: Wed, 30 Jul 2014 20:49:21 +0800 (GMT+08:00)
Message-ID: <151385e.14b46.14787515b85.Coremail.yizhouzhou@ict.ac.cn>
References: <1406708486-23427-1-git-send-email-zhouzhouyi@gmail.com>
 <20140730145119.c2c31dabf1a4f7012522fa95@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Zhouyi Zhou" <zhouzhouyi@gmail.com>, rdunlap@infradead.org,
	davem@davemloft.net, minipli@googlemail.com, brouer@redhat.com,
	steffen.klassert@secunet.com, fan.du@windriver.com,
	dborkman@redhat.com, fengguang.wu@intel.com, tgraf@suug.ch,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Dmitry Popov" <ixaphire@qrator.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140730145119.c2c31dabf1a4f7012522fa95@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for reviewing.
I did miss it.
> -----Original Messages-----
> From: "Dmitry Popov" <ixaphire@qrator.net>
> Sent Time: Wednesday, July 30, 2014
> To: "Zhouyi Zhou" <zhouzhouyi@gmail.com>
> Cc: rdunlap@infradead.org, davem@davemloft.net, minipli@googlemail.com, brouer@redhat.com, steffen.klassert@secunet.com, fan.du@windriver.com, dborkman@redhat.com, fengguang.wu@intel.com, tgraf@suug.ch, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
> Subject: Re: [PATCH net-next] pktgen: add ttl option for pktgen
> 
> On Wed, 30 Jul 2014 16:21:26 +0800
> Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> 
> > I think it is useful to add ttl option for pktgen, for example
> > if a some ISP want to test its network quality, it could set 
> > ttl so that the tested links get the packet while end users won't
> > get it. 
> 
> It seems you're missing 
> 
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2799,7 +2799,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
> 
>     iph->ihl = 5;
>     iph->version = 4;
> -   iph->ttl = 32;
> +   iph->ttl = pkt_dev->ttl;
>     iph->tos = pkt_dev->tos;
>     iph->protocol = IPPROTO_UDP;    /* UDP */
>     iph->saddr = pkt_dev->cur_saddr;
