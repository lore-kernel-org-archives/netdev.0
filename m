From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 19:37:04 +0200
Message-ID: <20070919173704.GA3115@uranus.ravnborg.org>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net> <20070918203530.GC27836@uranus.ravnborg.org> <20070919171033.GH6618@stro.at> <46F15886.6040701@zytor.com> <20070919171841.GT19918@baikonur.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:45484 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762643AbXISRfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 13:35:40 -0400
Content-Disposition: inline
In-Reply-To: <20070919171841.GT19918@baikonur.stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Maks.

On Wed, Sep 19, 2007 at 07:18:41PM +0200, maximilian attems wrote:
> On Wed, Sep 19, 2007 at 10:12:38AM -0700, H. Peter Anvin wrote:
> > 
> > Could you give a concrete example?
> > 
> > 	-hpa
> 
> max@dual:~/src/klibc$ touch usr/utils/mount_main.c
> max@dual:~/src/klibc$ make
>   KLIBCCC usr/utils/mount_main.o
>   KLIBCLD usr/utils/static/halt
>   LN      usr/utils/static/reboot
>   LN      usr/utils/static/poweroff
>   KLIBCLD usr/utils/shared/halt
>   LN      usr/utils/shared/reboot
>   LN      usr/utils/shared/poweroff
>   KLIBCLD usr/utils/static/chroot
>   KLIBCLD usr/utils/static/dd
>   <snipp>

I do not recall the details at the moment but I recall I had to
do this tradeoff for some reasons.
I do not say it is not fixable but when I did the static-y support
I recall I took a shortcut or two under the assumption that everything
build by klibc was anyway so simple that compiling a bit too much was no harm.

Too buried with other stuff right now.
But feel free to poke me in roughly a month and I will take a deeper look.

	Sam
