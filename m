From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: [2.6.31-git17] WARNING: at kernel/hrtimer.c:648
	hres_timers_resume+0x40/0x50()/WARNING: at drivers/base/sys.c:353
	__sysdev_resume+0xc3/0xe0()
Date: Mon, 28 Sep 2009 20:38:33 +0200
Message-ID: <8db1092f0909281138t18a379d1qdf999b0610ed6414@mail.gmail.com>
References: <8db1092f0909270105x4b49daf8k268e453d2379020c@mail.gmail.com>
	 <2674af740909270127s464a3cb2xef5e7f4cd61b0eb7@mail.gmail.com>
	 <2674af740909270130h359a5d23taa7e8b63e6a18a4d@mail.gmail.com>
	 <8db1092f0909270325j67825cem82fc93cf19336d6f@mail.gmail.com>
	 <2674af740909270701u6febabdbpc5c772fabc193b32@mail.gmail.com>
	 <2674af740909270749u339671a1ia81d5736eeb750fa@mail.gmail.com>
	 <8db1092f0909270916k79d0c369ub93b5e8ddf66c979@mail.gmail.com>
	 <2674af740909271854v191d9768mc3d96f30998f8c01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, clemens@ladisch.de,
	venkatesh.pallipadi@intel.com, gregkh@suse.de,
	zambrano@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752606AbZI1Sic@vger.kernel.org>
In-Reply-To: <2674af740909271854v191d9768mc3d96f30998f8c01@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/9/28 Yong Zhang <yong.zhang0@gmail.com>:

>>
>
> If you could, then please do it. It can give us some helpful information.

Add patch and remove previous:
http://unixy.pl/maciek/download/kernel/2.6.31-git17/gumis/dmesg-debug.txt

s2disk&resume twice.

no "timekeeping_resume() called with IRQs enabled!".

I found some interesting thing, warnings appear only once, during
first s2disk, on second don't appear.

Regards
-- 
Maciej Rutecki
http://www.maciek.unixy.pl
