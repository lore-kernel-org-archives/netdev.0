From: Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [patch] net/ps3: Fix wireless AP connect error handling
Date: Fri, 24 Apr 2009 13:58:32 -0700
Message-ID: <49F227F8.2060504@am.sony.com>
References: <49D109B4.7020808@am.sony.com> <49F0EFB9.20709@am.sony.com> <20090424201446.GD3309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090424201446.GD3309-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 04/24/2009 01:14 PM, John W. Linville wrote:
> On Thu, Apr 23, 2009 at 03:46:17PM -0700, Geoff Levand wrote:
>> From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
>> 
>> This patch fixes the bug that the driver tries to continue to
>> connect(associate) to AP even if gelic_wl_do_{wpa,wep}_setup() fails,
>> 
>> Signed-off-by: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
>> Signed-off-by: Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
>> ---
>> Hi John,
>> 
>> I didn't see this get merged in to 2.6.30 yet.  Could you let me know the status?
>> 
>> -Geoff
> 
> I have it queued for 2.6.31.  Does it cause a crash or other problem
> serious enough to merit pushing it for 2.6.30?

I saw this was merge to Linus's tree this morning.
Here is the commit: c6dbe17f193c4adc8afc6884f26efb5fa27aa8af

Sorry for the false alarm.

-Geoff

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
