From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: move Novatel 551 and E362 to qmi_wwan
Date: Wed, 24 Oct 2012 15:21:29 -0700
Message-ID: <20121024222129.GA1887@kroah.com>
References: <1351103134.6544.25.camel@dcbw.foobar.com>
 <1351103720.6544.34.camel@dcbw.foobar.com>
 <87objr659w.fsf@nemi.mork.no>
 <1351116634.16726.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Aleksander Morgado <aleksander-mXXj517/zsQ@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351116634.16726.6.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 24, 2012 at 05:10:34PM -0500, Dan Williams wrote:
> These devices provide QMI and ethernet functionality via a standard CDC
> ethernet descriptor.  But when driven by cdc_ether, the QMI
> functionality is unavailable because only cdc_ether can claim the USB
> interface.  Thus blacklist the devices in cdc_ether and add their IDs to
> qmi_wwan, which enables both QMI and ethernet simultaneously.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
> Greg: CC-ed to linux-usb@ for visibility but should probably go through davem

Yes, it should go through netdev:

Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
