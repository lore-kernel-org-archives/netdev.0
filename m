From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: pull request: wireless 2012-01-04
Date: Wed, 04 Jan 2012 11:40:54 -0600
Message-ID: <4F048F26.5000804@lwfinger.net>
References: <20120104155816.GE2540@tuxdriver.com> <20120104163109.GF2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120104163109.GF2540-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/04/2012 10:31 AM, John W. Linville wrote:
> On Wed, Jan 04, 2012 at 10:58:16AM -0500, John W. Linville wrote:
>
>> I was hesitant to include the rtlwifi fix, but settled on inclusion
>> because it was a product of a recent ginormous thread about the
>> intersection of firmware loading and suspend/resume.  Plus it fixes
>> a bug report in the Red Hat Bugzilla. :-) If you don't think it is
>> worthy, let me know and I'll drop it from this release.
>
> It looks like this could generate a build warning...
>
> 	http://marc.info/?l=linux-wireless&m=132569396407866&w=2
>
> I'm getting cold feet on this one.  I withdraw this pull request --
> new one to follow soon!

John,

I will resubmit this patch with a fix.

I now realize that my fix has a different problem in that the firmware might not 
be preserved under certain scenarios if there were two instances of the device 
sharing the driver. These are corner cases, but I would like to fix that as well.

Is there any way for a driver to know that it is being initialized for a second 
device?

Thanks,

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
