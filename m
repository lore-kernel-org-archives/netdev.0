From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Mon, 25 Jan 2010 19:28:39 -0800
Message-ID: <20100125192839.7eaceb2b.akpm@linux-foundation.org>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	<20100125170816.db9435ed.akpm@linux-foundation.org>
	<1264471333.373.349.camel@localhost>
	<20100125181508.790010cb.akpm@linux-foundation.org>
	<1264473168.373.354.camel@localhost>
	<4B5E5A5F.90608@moffatt.org.nz>
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
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40717 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751437Ab0AZD3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 22:29:47 -0500
In-Reply-To: <4B5E5A5F.90608@moffatt.org.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2010 15:58:39 +1300 Michael <michael@moffatt.org.nz> wrote:

> Hi guys,
> 
> I think I'm the submitter that Ben is referring to.
> 
> So that could be the answer to the kernel BUG I have reported, but I 
> don't think that it will answer why the interface doesn't come up... or 
> does it?

>From this:

Jan 21 05:08:26 172 kernel: starfire: Failed to load firmware "adaptec/starfire_rx.bin"
Jan 21 05:08:26 172 kernel: device eth4 entered promiscuous mode
Jan 21 05:08:26 172 kernel: starfire 0000:03:06.0: firmware: requesting adaptec/starfire_rx.bin
Jan 21 05:08:26 172 kernel: starfire: Failed to load firmware "adaptec/starfire_rx.bin"
Jan 21 05:08:26 172 kernel: device eth5 entered promiscuous mode
Jan 21 05:08:26 172 kernel: starfire 0000:03:07.0: firmware: requesting adaptec/starfire_rx.bin
Jan 21 05:08:26 172 kernel: starfire: Failed to load firmware "adaptec/starfire_rx.bin"
Jan 21 05:08:26 172 kernel: device eth6 entered promiscuous mode
Jan 21 05:08:26 172 kernel: starfire 0000:04:04.0: firmware: requesting adaptec/starfire_rx.bin

I assume that it can't find the firmware?
