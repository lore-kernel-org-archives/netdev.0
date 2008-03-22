From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Sat, 22 Mar 2008 12:29:57 +0100
Message-ID: <47E4EDB5.2080205@s5r6.in-berlin.de>
References: <20080316184349.GA28543@khazad-dum.debian.net> <200803161246.23909.david-b@pacbell.net> <20080318001429.896acf51.akpm@linux-foundation.org> <20080320225612.GB20788@khazad-dum.debian.net> <20080320164741.734e838c.akpm@linux-foundation.org> <20080321003604.GC20788@khazad-dum.debian.net> <20080320180802.426ad2d1.akpm@linux-foundation.org> <47E37E04.3080303@s5r6.in-berlin.de> <20080321123708.GE5586@khazad-dum.debian.net> <47E3B528.6010200@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47E3B528.6010200-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I wrote:
>>> and eth1394 to deal with temporary lack of of tlabels.  Alas I just  
>>> recently received a report that eth1394's workaround is unsuccessful 
>>> on  non-preemptible uniprocessor kernels.  
> (I haven't started working on a fix, or opened a bugzilla 
> ticket for it yet.  The reporter currently switched his kernel to 
> PREEMPT which is not affected.)

now logged as http://bugzilla.kernel.org/show_bug.cgi?id=10306

> The failure in the workaround is *not* about the in_atomic() being the 
> wrong question asked in hpsb_get_tlabel() --- no, ieee1394's in_atomic() 
> abuse works just fine even on UP PREEMPT_NONE.  Instead, the failure is 
> about kthreads not being scheduled in the way that I thought they would.
-- 
Stefan Richter
-=====-==--- --== =-==-
http://arcgraph.de/sr/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
