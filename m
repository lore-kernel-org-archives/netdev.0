From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Wed, 12 Dec 2007 08:27:39 +0900
Message-ID: <b25c3fa70712111527p561b3e2i24ee0fdf3d61a98c@mail.gmail.com>
References: <001801c83bd6$2001d410$9c94fea9@jason>
	 <20071211.023218.31965443.davem@davemloft.net>
	 <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:2835 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbXLKX1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 18:27:40 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2724wah.23
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 15:27:39 -0800 (PST)
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/12, Brandeburg, Jesse <jesse.brandeburg@intel.com>:
> Joonwoo Park wrote:
> >     /* If no Tx and not enough Rx work done, exit the polling mode */
> >     if ((!tx_cleaned && (work_done == 0)) ||
> >        !netif_running(poll_dev)) {
> > quit_polling:
> >         if (likely(adapter->itr_setting & 3))
> >             e1000_set_itr(adapter);
> >         netif_rx_complete(poll_dev, napi);
> >         e1000_irq_enable(adapter);
>
> all drivers using NAPI in 2.6.24+ (NNAPI??) must return zero here, after
> calling netif_rx_complete.  netif_rx_complete plus work_done != 0 causes
> a bug.
>
> >     }
> >
> >     return work_done;
> > }
> >
>

I'm working another patch for drivers (maybe patches)

Thanks.
Joonwoo
