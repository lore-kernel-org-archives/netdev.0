From: Jon Mason <mason@myri.com>
Subject: Re: 3.1-rc4: spectacular kernel errors / filesystem crash
Date: Tue, 13 Sep 2011 10:35:29 -0500
Message-ID: <CAMaF-rN-qeXBDoc9=7kwu40Wj8=G8YuPKWXPRhOuhdYX_VO34w@mail.gmail.com>
References: <alpine.DEB.2.02.1109110511250.8626@p34.internal.lan>
	<CAEuXFEzs1f7n5taYzupux3AtKmRcY4P0m7yjkUQA8aLyS8eujw@mail.gmail.com>
	<1315886706.2556.11.camel@edumazet-laptop>
	<alpine.DEB.2.02.1109130722210.21380@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Alan Piszcz <ap@solarrain.com>,
	NetDEV list <netdev@vger.kernel.org>, xfs@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1109130722210.21380@p34.internal.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2011 at 9:54 AM, Justin Piszcz <jpiszcz@lucidpixels.com=
> wrote:
>
>
> On Tue, 13 Sep 2011, Eric Dumazet wrote:
>
>> Please Justin make sure you pulled commit
>> commit ed2888e906b56769b4ffabb9c577190438aa68b8
>> Author: Jon Mason <mason@myri.com>
>> Date: =A0 Thu Sep 8 16:41:18 2011 -0500
>>
>> =A0 PCI: Remove MRRS modification from MPS setting code
>>
>> =A0 Modifying the Maximum Read Request Size to 0 (value of 128Bytes)=
 has
>> =A0 massive negative ramifications on some devices. =A0Without knowi=
ng which
>> =A0 devices have this issue, do not modify from the default value wh=
en
>> =A0 walking the PCI-E bus in pcie_bus_safe mode. =A0Also, make pcie_=
bus_safe
>> =A0 the default procedure.
>>
>> =A0 Tested-by: Sven Schnelle <svens@stackframe.org>
>> =A0 Tested-by: Simon Kirby <sim@hostway.ca>
>> =A0 Tested-by: Stephen M. Cameron <scameron@beardog.cce.hp.com>
>> =A0 Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
>> =A0 Reported-and-tested-by: Niels Ole Salscheider
>> <niels_ole@salscheider-online.
>> =A0 References: https://bugzilla.kernel.org/show_bug.cgi?id=3D42162
>> =A0 Signed-off-by: Jon Mason <mason@myri.com>
>> =A0 Acked-by: Jesse Barnes <jbarnes@virtuousgeek.org>
>> =A0 Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> Hello,
>
> I found this commit here:
> http://permalink.gmane.org/gmane.linux.kernel.pci/11700

This is an early version of the patch.  This is the patch that you want=
:
https://github.com/torvalds/linux/commit/ed2888e906b56769b4ffabb9c57719=
0438aa68b8

It appears that this patch didn't make it to lkml or linux-pci list
due to kernel.org DNS being down when it was sent.

Thanks,
Jon

>
> Applied:
> # patch -p1 < ../ed2888e906b56769b4ffabb9c577190438aa68b8.txt patchin=
g file
> drivers/pci/probe.c
>
> I will update this thread if the problem recurs, can someone also ple=
ase
> advise
> which DEBUG options I should have enabled to catch further SLAB/RCU i=
ssues?
>
> So far, I have the following enabled:
>
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
> CONFIG_HAVE_DMA_API_DEBUG=3Dy
> CONFIG_X86_DEBUGCTLMSR=3Dy
> CONFIG_DEBUG_FS=3Dy
> CONFIG_DEBUG_KERNEL=3Dy
> CONFIG_DEBUG_SLAB=3Dy
> CONFIG_DEBUG_SLAB_LEAK=3Dy
> CONFIG_DEBUG_KMEMLEAK=3Dy
> CONFIG_DEBUG_STACK_USAGE=3Dy
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> CONFIG_DEBUG_INFO=3Dy
> CONFIG_DEBUG_VM=3Dy
> CONFIG_DEBUG_VIRTUAL=3Dy
> CONFIG_DEBUG_MEMORY_INIT=3Dy
> CONFIG_DEBUG_PER_CPU_MAPS=3Dy
> CONFIG_DEBUG_PAGEALLOC=3Dy
> CONFIG_DEBUG_STACKOVERFLOW=3Dy
> CONFIG_DEBUG_RODATA=3Dy
>
> Thanks,
>
> Justin.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
