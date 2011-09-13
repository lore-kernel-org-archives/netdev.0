From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: 3.1-rc4: spectacular kernel errors / filesystem crash
Date: Tue, 13 Sep 2011 11:42:38 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1109131142010.7113@p34.internal.lan>
References: <alpine.DEB.2.02.1109110511250.8626@p34.internal.lan> <CAEuXFEzs1f7n5taYzupux3AtKmRcY4P0m7yjkUQA8aLyS8eujw@mail.gmail.com> <1315886706.2556.11.camel@edumazet-laptop> <alpine.DEB.2.02.1109130722210.21380@p34.internal.lan>
 <CAMaF-rN-qeXBDoc9=7kwu40Wj8=G8YuPKWXPRhOuhdYX_VO34w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="655872-1916408521-1315928558=:7113"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Alan Piszcz <ap@solarrain.com>,
	NetDEV list <netdev@vger.kernel.org>, xfs@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:44044 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab1IMPmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 11:42:38 -0400
In-Reply-To: <CAMaF-rN-qeXBDoc9=7kwu40Wj8=G8YuPKWXPRhOuhdYX_VO34w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--655872-1916408521-1315928558=:7113
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 13 Sep 2011, Jon Mason wrote:

> On Tue, Sep 13, 2011 at 9:54 AM, Justin Piszcz <jpiszcz@lucidpixels.com> =
wrote:
>>
>>
>> On Tue, 13 Sep 2011, Eric Dumazet wrote:
>>
>>> Please Justin make sure you pulled commit
>>> commit ed2888e906b56769b4ffabb9c577190438aa68b8
>>> Author: Jon Mason <mason@myri.com>
>>> Date: =A0 Thu Sep 8 16:41:18 2011 -0500
>>>
>>> =A0 PCI: Remove MRRS modification from MPS setting code
>>>
>>> =A0 Modifying the Maximum Read Request Size to 0 (value of 128Bytes) ha=
s
>>> =A0 massive negative ramifications on some devices. =A0Without knowing =
which
>>> =A0 devices have this issue, do not modify from the default value when
>>> =A0 walking the PCI-E bus in pcie_bus_safe mode. =A0Also, make pcie_bus=
_safe
>>> =A0 the default procedure.
>>>
>>> =A0 Tested-by: Sven Schnelle <svens@stackframe.org>
>>> =A0 Tested-by: Simon Kirby <sim@hostway.ca>
>>> =A0 Tested-by: Stephen M. Cameron <scameron@beardog.cce.hp.com>
>>> =A0 Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> =A0 Reported-and-tested-by: Niels Ole Salscheider
>>> <niels_ole@salscheider-online.
>>> =A0 References: https://bugzilla.kernel.org/show_bug.cgi?id=3D42162
>>> =A0 Signed-off-by: Jon Mason <mason@myri.com>
>>> =A0 Acked-by: Jesse Barnes <jbarnes@virtuousgeek.org>
>>> =A0 Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>> Hello,
>>
>> I found this commit here:
>> http://permalink.gmane.org/gmane.linux.kernel.pci/11700
>
> This is an early version of the patch.  This is the patch that you want:
> https://github.com/torvalds/linux/commit/ed2888e906b56769b4ffabb9c5771904=
38aa68b8
>
> It appears that this patch didn't make it to lkml or linux-pci list
> due to kernel.org DNS being down when it was sent.
>
> Thanks,
> Jon

I need to learn how to use git at some point, can you please provide plain
text patches so I can apply them and reboot?

Justin.

--655872-1916408521-1315928558=:7113--
