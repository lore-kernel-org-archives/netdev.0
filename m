From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Thu, 16 Jun 2011 20:06:44 +0200
Message-ID: <BANLkTikE-oc2qWZec+2BfWuUy-oNdf-opg@mail.gmail.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
 <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com> <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 7:20 PM, Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org> wrote:
> It does seem we are missing an IB_MANDATORY_FUNC
> entry for modify_port in ib_device_check_mandatory; or on
> the flip side we are missing a check of modify_port and a
> -ENOSYS return... I guess modify_port does not really make
> sense for iWARP so probably the second option is better.

It's not just ib_modify_port() - there are several other functions in
the amso and cxgb* drivers that do nothing more than returning either
-ENOSYS or ERR_PTR(-ENOSYS).

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
