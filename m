From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-10-08
Date: Fri, 9 Oct 2009 01:16:44 +0200
Message-ID: <200910090116.46513.mb@bu3sch.de>
References: <20091008223454.GB2798@tuxdriver.com> <200910090108.08838.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200910090108.08838.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 October 2009 01:08:06 Michael Buesch wrote:
> On Friday 09 October 2009 00:34:54 John W. Linville wrote:
> > Albert Herranz (1):
> >       b43: do not stack-allocate pio rx/tx header and tail buffers
> 
> Come on, this is _not_ funny anymore. I did _not_ ack this patch, because I do _not_ like it.
> I was planning to do a better solution, but I didn't have the time, yet.
> Can you _please_ either:
> - Wait for my ack before you apply random b43 patches
> or
> - Remove me from MAINTAINERS
> 

And there's no reason to rush this fix into mainline. We currently do not even
have a supported device which would require this fix. The Wii, which uses the SDIO bus,
does not require this fix. So the only supported device (as of now) does not need the fix
to work properly.
So it can as well go into the next merge window.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
