From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 2/3] cdc_ether: allow vendor specific data interface if control interface is vendor specific
Date: Tue, 13 Dec 2011 05:59:12 +0100
Message-ID: <87vcplcbj3.fsf@nemi.mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	<1323750784-32608-3-git-send-email-bjorn@mork.no>
	<1323752053.3837.17.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323752053.3837.17.camel@joe2Laptop> (Joe Perches's message of
	"Mon, 12 Dec 2011 20:54:13 -0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> On Tue, 2011-12-13 at 05:33 +0100, Bjorn Mork wrote:
>> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether=
=2Ec
> []
>> @@ -211,8 +211,12 @@ int usbnet_generic_cdc_bind(struct usbnet *dev,=
 struct usb_interface *intf)
> []
>> -				dev_dbg(&intf->dev, "slave class %u\n",
> []
>> +				dev_dbg(&intf->dev, "xslave class %u\n",
>
> Why change the output from slave to xslave?

That was unintentional.  Sorry.  Don't understand how checkpatch could
have missed that :-)

Will fix and submit again, unless there are objections to the actual
code change.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
