From: Harsh <hanemade@gmail.com>
Subject: Re: help in using eth_change_mtu
Date: Tue, 25 Jan 2005 11:50:06 +0530
Message-ID: <cfc9593605012422204db19d04@mail.gmail.com>
References: <cfc9593605012400595e529682@mail.gmail.com>
	 <41F5C109.7060801@gmail.com>
Reply-To: Harsh <hanemade@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Neema <neema.network@gmail.com>
In-Reply-To: <41F5C109.7060801@gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello ,
             Extra info mean IPSEC headers. How can they sent in
2.4.24 kernel? where can i find Packets being using IPSEC headers and
is that require to reduce MTU by AH/ESP header bytes???
            Also can you tellme in which condition eth_change_mtu used?
reagards,
Harsh.


On Tue, 25 Jan 2005 09:16:17 +0530, Neema <neema.network@gmail.com> wrote:
> Hi,
> 
>     What ever u may send,the maximum size of the packet in ethernet
> should be 1514bytes, that includes ethernet header (And also minimum is
> 82bytes).
> I think u are using old libnet version. That function sets the MTU with
> the given value if neither exceeded max and nor minimum.
> 
> HTH,
> Neema
> 
> Harsh wrote:
> 
> >Hello,
> >         If some extra information is required to be sent with each
> >packet then does that require to change Ethernet MTU 1500 to
> >1500-(Bytes in extra info) or its ok with 1500 value of MTU? While
> >checking source code of net_init.c in drivers/net dir i found one
> >function eth_change_mtu. I want to know does that helps? why its given
> >there in source code?
> >regards,
> >Harsh.
> >
> >static int eth_change_mtu(struct net_device *dev, int new_mtu)
> > {
> >        if ((new_mtu < 68) || (new_mtu > 1500))
> >                 return -EINVAL;
> >        dev->mtu = new_mtu;
> >        return 0;
> > }
> >-
> >To unsubscribe from this list: send the line "unsubscribe linux-net" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> >
> 
> --
> 
> Thanks & Regards,
> Neema
> 
>
