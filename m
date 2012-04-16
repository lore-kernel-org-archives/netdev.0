From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Patch for man unix(7)
Date: Mon, 16 Apr 2012 20:08:41 +0900
Message-ID: <201204162008.GGI81741.VHFtOLFJSMOQFO@I-love.SAKURA.ne.jp>
References: <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
	<201010262115.FEH09326.OMFJHSVOFLQFOt@I-love.SAKURA.ne.jp>
	<201011232159.DFE78143.tSHMFQOLFVFJOO@I-love.SAKURA.ne.jp>
	<CAKgNAkgNRbdcWwo0nhsbCxtnagEucxm6d76ugGAAUAd+ukBLCQ@mail.gmail.com>
	<CAKgNAki82=5=SkYkfXuF08YMMZ4dpYvORmWQ5OSkQx6Uhahqdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man@vger.kernel.org, netdev@vger.kernel.org
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:59851 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab2DPLIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 07:08:47 -0400
In-Reply-To: <CAKgNAki82=5=SkYkfXuF08YMMZ4dpYvORmWQ5OSkQx6Uhahqdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Kerrisk (man-pages) wrote:
> >> Therefore, the caller of getsockname(), getpeername(), accept() must not assume
> >> that sunaddr->sun_path contains a null-terminated pathname even if the returned
> >> addrlen is greater than sizeof(sa_family_t) and sun_path[0] != '\0'.
> >
> > Thanks. I see what you mean. However, I'm wondering, is the kernel
> > behavior simply a bug that should be fixed, so that a null terminator
> > is always placed in sun_path?

I thought it is a bug, but according to thread starting from
http://lkml.indiana.edu/hypermail/linux/kernel/0503.3/0954.html ,
sun_path seems to be designed to accept pathname without null terminator.
