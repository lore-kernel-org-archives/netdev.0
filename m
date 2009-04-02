From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] hso: fix for the 'invalid frame length' messages
Date: Thu, 02 Apr 2009 10:34:02 +0200
Message-ID: <49D4787A.6060808@option.com>
References: <20090330094459.GC9849@raptor> <20090402.012032.67869929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090402.012032.67869929.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 30 Mar 2009 11:44:59 +0200
> 
>> Some devices cannot send very short usb transfers. To get around this the
>> firmware adds a known pattern and flags the driver that it should check for
>> this pattern on short transfers. This flag was not taken into account by
>> the driver.
>>
>> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> 
> These patches do not apply cleanly, please respin them against the
> current sources.

The diff was taken against 2.6.29, problem is that they both change the same file (as did the
product ID patch) and that changes the line numbers...
Against which sources should I take them again and should I start from the same clean sources for
each patch or can they be "stacked" ?

Greets.
Jan.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
