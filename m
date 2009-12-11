From: Ian Marsh <mushypea@dominion.net.uk>
Subject: Re: r8169
Date: Fri, 11 Dec 2009 14:58:24 +0000
Message-ID: <20091211145824.GB19780@slinky.marshes.co.uk>
References: <20091210205821.GX6965@slinky.marshes.co.uk> <4B220E3D.5030502@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slinky.marshes.co.uk ([80.45.84.194]:32873 "EHLO
	slinky.marshes.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758591AbZLKO6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 09:58:24 -0500
Content-Disposition: inline
In-Reply-To: <4B220E3D.5030502@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Franco,

Thanks for your reply.

On Fri 11 Dec 2009 at 10:17:49 +0100, Franco Fichtner wrote:
> At work we're also using ubuntu which comes with the r8169 driver,
> and had to deal with network dropouts while trying to benchmark
> heavy loads. This is what the support of our boxes told us:
>
>> Please use 8168 instead of 8169. Please see the notice about this
>> important point in May..
>>
>> The situation you observed should be a misjudgment by the Linux Kernel.
>> Driver 8168 is recommended by Realtek. Please use this revision.

I have tried the 8168 driver, and get the same problem.  I followed this
process:

1) rmmod the 8169 driver
2) blacklist the 8169 driver
3) install the 8168 driver
4) rebuild initramfs
5) reboot

Symptoms are identical; it loads the module, gets an IP, pings, fetches Google
okay, but nothing more substantial.

I believe I tried 8.014.00 with a patch to make it compile for 2.6.31 (from
www.jamesonwilliams.com/bin/r8168_scripts.tar.bz2 ).  I don't think I could
get 8.015.00 from www.realtek.com.tw to compile at all, but can't check at the
moment.

When searching for a solution, I did come across several different problems
with the r8169 driver, mostly believed to be fixed in earlier kernels, and
tried several fixs/workarounds to no avail.

Ian.
