From: d@taht.net (Dave =?utf-8?Q?T=C3=A4ht?=)
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 08:31:41 -0700
Message-ID: <87fwr9jxya.fsf@cruithne.co.teklibre.org>
References: <20110225222210.GA3618@tuxdriver.com>
	<AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Sedat Dilek's message of "Sun, 27 Feb 2011 16:23:59 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:

> On Fri, Feb 25, 2011 at 11:22 PM, John W. Linville
> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>> Announcement
>>
>> The bufferbloat project [1] is pleased to announce the availability
>> of the debloat-testing Linux kernel git tree:
>>
>>   git://git.infradead.org/debloat-testing.git

----snip----

> Hi,
>
> it should be "localversion-debloat" in the commit-subject in [1] (not
> "localversion-wireless") :-).  "-db" as suffix is IMHO not very
> meaningful... Why not add simply a suffix called "-debloat"?  (Anyway,
> I will revert this patch because I don't want to have any suffix added
> automatically.)
>
> I have several other questions, but I start compiling first and test
> this debloat kernel.

Excellent. At moment I would recommend building "low latency preempt
desktop" kernels with a high HZ value (400 or 1000), enabling highres
timers, and compiling in SFB as a module. (I'd like the default for SFB
to be "m" rather than "n", too)

>
> Regards,
> - Sedat -
>
> [1] "Add localversion-wireless to identify builds from this tree."
> http://git.infradead.org/debloat-testing.git/commit/3f9bdb4f44b076feda72d353d8ad717831416f36
> _______________________________________________
> Bloat-devel mailing list
> Bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
> https://lists.bufferbloat.net/listinfo/bloat-devel

-- 
Dave Taht
http://nex-6.taht.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
