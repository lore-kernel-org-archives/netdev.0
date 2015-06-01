From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 01 Jun 2015 09:48:26 +0200
Message-ID: <1433144906.1557.2.camel@suse.com>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain>
	 <20150601005917.GB5320@kroah.com>
	 <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.20.1506010818110.3158-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-06-01 at 08:53 +0200, Enrico Mioso wrote:

> A 32-bit version of the driver (talking 32-bit NCM) is here:
> http://www.gstorm.eu/cdc_ncm.c
> I modified the original driver with the help of a very talented friend.
> It works: but there seem to be no real reasons to implement this properly. We 
> did this in a consistent effort to understand what was wrong, and here it is.

Well, you are really talking about two different things here.
Do we ever fail because we only do 16 bit as opposed to 32 bit?
Your 32 bit driver looks good, but it raises the question of what to do
if this test:

        if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) &
                                                USB_CDC_NCM_NTB32_SUPPORTED) {

fails. Otherwise it looks ready for merging.

	Regards
		Oliver



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
