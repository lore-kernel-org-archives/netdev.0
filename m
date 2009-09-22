From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 64-bit DMA support
Date: Tue, 22 Sep 2009 13:53:56 +0200
Message-ID: <20090922115356.GB13710@electric-eye.fr.zoreil.com>
References: <4AB6BCEC.3070001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37580 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756116AbZIVLs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 07:48:28 -0400
Content-Disposition: inline
In-Reply-To: <4AB6BCEC.3070001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Hancock <hancockrwd@gmail.com> :
[...]
> It's not clear (from the mails I've read) exactly what was going on in  
> the case that caused this to be added.

Some AMD + r8169 systems simply did not work.

> Normally these days the PCI subsystem is supposed to detect that DAC
> isn't usable on a machine and refuse setting 64-bit DMA masks, it's
> not the driver's responsibility to handle this.
> I'm guessing that when this change was made that detection didn't exist
> though.

Not exactly. It was required for DAC to be explicitely enabled through
the CPlusCmd register.

> Thoughts on whether this default can be changed now ?

The 8168 does not seem to need the CPlusCmd stuff. I'll check it but it
should be possible to enable high DMA without condition for it.

-- 
Ueimor
