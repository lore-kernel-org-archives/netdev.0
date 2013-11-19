From: hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net v3 1/4] r8152: fix tx/rx memory overflow
Date: Tue, 19 Nov 2013 10:32:47 +0800
Message-ID: <701E277A875F4A69A1B3C5B306B7CE8B@realtek.com.tw>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com><1384502279-9959-2-git-send-email-hayeswang@realtek.com> <20131115.173948.1712849813995511721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, 'nic_swsd' <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131115.173948.1712849813995511721.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
> Sent: Saturday, November 16, 2013 6:40 AM
> To: Hayeswang
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; nic_swsd; 
> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH net v3 1/4] r8152: fix tx/rx memory overflow
> 
> From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
> Date: Fri, 15 Nov 2013 15:57:56 +0800
> 
> > +			unsigned pkt_len;
> 
> Please fully specify the type as "unsigned int".  Please 
> check for this
> problem in the rest of your patches too.

I would fix it.

I check the other patches, and I don't find the same problem.

Thanks.
 
Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
