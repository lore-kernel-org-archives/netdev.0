From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 22:35:30 +0200
Message-ID: <20070918203530.GC27836@uranus.ravnborg.org>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hpa@zytor.com, mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:47294 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbXIRUeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 16:34:06 -0400
Content-Disposition: inline
In-Reply-To: <20070918.130810.78161599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 01:08:10PM -0700, David Miller wrote:
> From: "H. Peter Anvin" <hpa@zytor.com>
> Date: Tue, 18 Sep 2007 12:27:04 -0700
> 
> > Well, what I was referring to here, of course, was the initramfs
> > integrated in the kernel image, so it all comes out of the kernel build
> > tree and produces a single bootable image.  The fact that part of it
> > contains userspace code is in that way invisible.
> > 
> > That was kind of the point here, and the only reason for pushing klibc
> > into the kernel build tree at all.  Under the "distros use external
> > initrd anyway" school of thought, whatever libc used for that can be
> > external anyway.
> 
> Sounds good to me :)

Except there seems to be great resistance to include userland code in the
kernel as demonstrated at last KS. Or this is maybe just a single vocal
person and the topic were brought up late?

Anyway - if we again consider klibc I will do my best to make the
build stuff as smooth as possible.

	Sam
