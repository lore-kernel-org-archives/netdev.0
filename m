From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Fri, 31 Aug 2007 09:30:50 -0400
Message-ID: <46D8180A.5070902@garzik.org>
References: <2713029743177393055@pripojeni.net>	 <280951420471148977@pripojeni.net> <20070828171330.GD29343@infradead.org>	 <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>	 <20070830123609.GA5140@tuxdriver.com> <1188561531.2668.7.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1188561531.2668.7.camel-xTRJqYXIWqq1Tluu+1bJKiZi+YwRKgec@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Thu, 2007-08-30 at 08:36 -0400, John W. Linville wrote:
>> On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
>>> 2007/8/28, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>:
>>>> Also this whole patch seems rather pointless.  It saves only
>>>> very little and turns the driver into a complete ifdef maze.
>>> Also most
>>> people will use 5212 code only, 5211 cards are on some old laptops and
>>> 5210, well i couldn't even find  a 5210 for actual testing :P
>> FWIW, I'd bet dollars to donuts that distros will enable them all
>> together.
> 
> I would certainly _hope_ that distros enable everything -that is in the
> kernel- that they can get their hands on, otherwise when you stick a
> card in, it doesn't just work.

Distros definitely -do not- do this.  Plenty of ancient ISA drivers are 
disabled at build time, for example, in many distros.

	Jeff
