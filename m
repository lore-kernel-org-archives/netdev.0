From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2016-09-29
Date: Thu, 29 Sep 2016 20:21:17 +0200
Message-ID: <20160929182117.GA18734@salvia>
References: <87ponmve2v.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ponmve2v.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2016 at 07:57:28PM +0300, Kalle Valo wrote:
> Hi Dave,
> 
> this should be the last wireless-drivers-next pull request for 4.9, from
> now on only important bugfixes. Nothing really special stands out,
> iwlwifi being most active but other drivers also getting attention. More
> details in the signed tag. Please let me know if there are any problems.
> 
> Or actually I had one problem. While doing a test merge I noticed that
> net-next fails to compile for me, but I don't think this is anything
> wireless related:
> 
>   CC      net/netfilter/core.o
> net/netfilter/core.c: In function 'nf_set_hooks_head':
> net/netfilter/core.c:96:149: error: 'struct net_device' has no member named 'nf_hooks_ingress'

That's my problem, will be sending a pull request to fix this asap,
thanks.
