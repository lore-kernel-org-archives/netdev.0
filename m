From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: move Novatel 551 and E362 to qmi_wwan
Date: Thu, 25 Oct 2012 09:17:13 +0200
Message-ID: <87ehkn58cm.fsf@nemi.mork.no>
References: <1351103134.6544.25.camel@dcbw.foobar.com>
	<1351103720.6544.34.camel@dcbw.foobar.com>
	<87objr659w.fsf@nemi.mork.no>
	<1351116634.16726.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aleksander Morgado <aleksander-mXXj517/zsQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351116634.16726.6.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Wed, 24 Oct 2012 17:10:34 -0500")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> These devices provide QMI and ethernet functionality via a standard C=
DC
> ethernet descriptor.  But when driven by cdc_ether, the QMI
> functionality is unavailable because only cdc_ether can claim the USB
> interface.  Thus blacklist the devices in cdc_ether and add their IDs=
 to
> qmi_wwan, which enables both QMI and ethernet simultaneously.

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
