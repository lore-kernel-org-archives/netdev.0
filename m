From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Mon, 25 Jan 2010 21:57:15 -0800
Message-ID: <20100125215715.4486c5fc.akpm@linux-foundation.org>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	<20100125170816.db9435ed.akpm@linux-foundation.org>
	<1264471333.373.349.camel@localhost>
	<20100125181508.790010cb.akpm@linux-foundation.org>
	<1264473168.373.354.camel@localhost>
	<4B5E5A5F.90608@moffatt.org.nz>
	<20100125192839.7eaceb2b.akpm@linux-foundation.org>
	<4B5E82CB.6040001@moffatt.org.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Michael <michael@moffatt.org.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46439 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751368Ab0AZF6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 00:58:24 -0500
In-Reply-To: <4B5E82CB.6040001@moffatt.org.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2010 18:51:07 +1300 Michael <michael@moffatt.org.nz> wrote:

> Yep, OK, I hadn't seen that log in dmesg.
> 
> That driver is new to me, it's never turned up (or been required) before 
> so that must be new between 2.6.24 and 2.6.32.
> 
> As this is a root over nfs system, the kernel is compiled elsewhere and 
> then installed manually. What I was missing was that there is a new 
> adaptec directory that needed to be copied from 
> /usr/src/linux-2.6.32/firmware/ to /lib/2.6.32. Actually, I am not sure 
> that this is the right place for it (rather than say 
> /lib/firmware/2.6.32|, but it seems to work anyway.
> 
> Quite a gotchya. After compiling a kernel on a separate compiling 
> system, I don't actually run the 'make install' on the nfs system. 
> Previously I used to run the 'make install' on a dedicated compiling 
> server and then just copy the modules from that system into the root 
> over nfs exported /lib/modules directory. That'd worked fine up until now.
> 
> I will have to find a cleverer way to copy over the new firmware libs 
> for future compiles. The 'make install' seems to copy firmware objects 
> into the compiling system's /lib/firmware/ directory without 
> distinguishing the kernel version. So I can't easily tell which ones I'm 
> supposed to be copying into the nfs export.
> 
> Many thanks for all your help. The interfaces are up and apparently you 
> understand where the kernel BUG came from.
> 
> So does that complete the story now? In other words, is there anything 
> further you need from me.

Well, it'd be great if you could test Ben's patch with the firmware
file inaccessible, and confirm that the kernel doesn't crash/freeze/etc.

Thanks.
