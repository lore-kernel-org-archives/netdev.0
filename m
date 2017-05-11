From: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Thu, 11 May 2017 18:56:59 +0200
Message-ID: <20170511165659.GB20043@lst.de>
References: <20170501163311.GA22209@lst.de> <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com> <1493750358.2552.13.camel@sandisk.com> <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me> <20170504084825.GA5399@lst.de> <869d9fb6-0d83-5f57-f8e4-5c1ee7477b94@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>, Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <869d9fb6-0d83-5f57-f8e4-5c1ee7477b94-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2017 at 06:50:04PM +0200, Ursula Braun wrote:
> Please consider the following patch to make users aware of the
> security implications through existing mechanisms.

Any such patch would be in addition to the BROKEN marker until
there is an actual alternative.

> +		rmb_desc->mr_rx[SMC_SINGLE_LINK] =
> +			lgr->lnk[SMC_SINGLE_LINK].roce_pd->__internal_mr;

And it's named __internal_mr for reason.  The right interface to use
the unsafe rkey is to use pd->unsafe_global_rkey.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
