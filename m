From: Albert Herranz <albert_herranz-mRCrAkd8dF0@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix spinlock recursion
Date: Wed, 14 Mar 2012 19:04:43 +0100
Message-ID: <4F60DDBB.2080704@yahoo.es>
References: <1331732727-16665-1-git-send-email-mvs@tigris.de> <20120314154211.GA6101@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Maximilian Schwerin <mvs-Uf0zVKHSUsGzQB+pC5nmwQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120314154211.GA6101-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/14/2012 04:42 PM, Greg KH wrote:
> On Wed, Mar 14, 2012 at 02:45:27PM +0100, Maximilian Schwerin wrote:
>> From: Albert Herranz <albert_herranz-mRCrAkd8dF0@public.gmane.org>
>>
>> This patch fixes the following spinlock recursion bug seen when bringing down
>> the ethernet interface.
>>
[...]
> Hint, use scripts/get_maintainer.pl to find the right person to send
> this patch to (you missed a list, and because of that, the patch will
> never get applied...)
> 
> thanks,
> 
> greg k-h
> 

Hi,

I think that David Miller already picked up a similar patch recently (with a different approach).

http://marc.info/?l=linux-netdev&m=133115161606222&w=2

Cheers,
Albert


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
