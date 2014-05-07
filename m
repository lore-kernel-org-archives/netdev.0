From: Tim Bird <tbird20d@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Wed, 7 May 2014 15:19:03 -0700
Message-ID: <CA+bK7J78WdJmH7omCKgOBDwr_qQV83xezoar89MQE=LYSeEthQ@mail.gmail.com>
References: <20140505.232327.578134514220748085.davem@davemloft.net>
	<1399351148.8767.84.camel@empanada>
	<20140507145938.79110827@alan.etchedpixels.co.uk>
	<20140507.132021.591444790908478214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gnomes@lxorguk.ukuu.org.uk, tom.zanussi@linux.intel.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140507.132021.591444790908478214.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 7, 2014 at 10:20 AM, David Miller <davem@davemloft.net> wrote:
> From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Date: Wed, 7 May 2014 14:59:38 +0100
>
>> 16MB of DRAM means adding a chip to your system. You've just exceeded the
>> space, power and cost budget on the very low end. In many cases like FPGA
>> systems you can't even add DRAM without major hoop jumping.
>
> A year or so for now this may not be true, which makes these kinds of changes
> very nearly in the "point in time solution" category.
>
> My main point in all of this is that whilst Linux should work on a braod range
> of system types, there has to be a limit somewhere and I think 2MB is off
> the deep end.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Linux 2.6.33 is currently running on a microcontroller with 2MB of flash
and 256K of RAM.  See Vitaly Wool's presentation from ELC about
this here:
http://elinux.org/images/c/ca/Spreading.pdf.
It might be off the deep end, but I think that's pretty exciting.

That's not a super-recent kernel, but I think current kernels could get
to 512K RAM and 2MB flash with some elbow grease.  That hits the
sweet spot for where the deep embedded processors (everything on-die,
at really aggressive price per unit) are heading in the next few years.

I sympathize with the arguments about increasing configuration complexity,
and the possibility of introducing bugs. "big switches" and LTO should both
help with the config complexity problem.  With regard to bugs, I think some
of  the patches may be a problem, and that's where the help of the
networking experts would be great in helping to avoid problems.  Dropping
optional features is going to happen on these devices whether it's Linux
running there or some RTOS.  Linux will certainly be talking to these
devices, if not running in them.  So your life on the host side might be
improved if you have some say what the stack looks like on the device
side.

If you don't want to help avoid problems, I understand.  All the kernel
maintainers are extremely busy.  But the use cases are pretty interesting,
and it would be nice to have you on board.

 -- Tim Bird
