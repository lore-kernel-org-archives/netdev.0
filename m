From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] net: sierra_net: device IDs for Aircard 320U++
Date: Wed, 06 Jun 2012 10:19:15 +0200
Message-ID: <87wr3kua2k.fsf@nemi.mork.no>
References: <20120605212414.GB6526@kroah.com>
	<1338967090-7119-1-git-send-email-bjorn@mork.no>
	<20120606081246.GB7306@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120606081246.GB7306-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> (Greg KH's message of "Wed, 6
	Jun 2012 17:12:46 +0900")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> writes:
> On Wed, Jun 06, 2012 at 09:18:10AM +0200, Bj=C3=B8rn Mork wrote:
>> Adding device IDs for Aircard 320U and two other devices
>> found in the out-of-tree version of this driver.
>>=20
>> Cc: linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
>> Cc: Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> ---
>>  drivers/net/usb/sierra_net.c |   14 ++++++++++----
>>  1 file changed, 10 insertions(+), 4 deletions(-)
>
> Wait, Tom just sent me a patch adding these device ids to the sierra
> serial driver, why would the same device work for both drivers?

Because it's a composite device.  Was this a trick question? :-)

>  Where should the device id go?

To both drivers.  The device is similar to the 1199:68a3 device already
supported by both drivers.  It has a number of serial ports (depending
on how many features like GPS etc is enabled) supported by the "sierra"
driver and one ethernet interface speaking Sierra's HIP protocol
supported by the "sierra_net" driver.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
