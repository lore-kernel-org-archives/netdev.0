From: Borislav Petkov <bp@alien8.de>
Subject: Re: Poor network performance x86_64.. also with 3.13
Date: Sun, 9 Feb 2014 19:49:06 +0100
Message-ID: <20140209184906.GC8487@pd.tnic>
References: <52DAD66F.7080306@dragonslave.de>
 <20140118195026.GA15543@pd.tnic>
 <52DB0439.2060905@dragonslave.de>
 <52DDA2CD.9040001@dragonslave.de>
 <20140120223752.GA3057@pd.tnic>
 <20140209160511.2f67866f@Mycroft>
 <20140209153107.GA8614@pd.tnic>
 <1391969674.10160.134.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Exner <dex@dragonslave.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:43043 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbaBIStL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Feb 2014 13:49:11 -0500
Content-Disposition: inline
In-Reply-To: <1391969674.10160.134.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 09, 2014 at 10:14:34AM -0800, Eric Dumazet wrote:
> tcp_rmem[2] = 16777
> 
> Come on, the 640KB barrier was broken a long time ago ;)
> 
> Feel free to investigate, I wont ;)

Me too - it's not like I don't have anything else to do. :-)

I was just wondering why 3.10 was fine even with these settings and 3.12
wasn't. Here's the original report:

"I recently upgraded the Kernel from version 3.10 to latest stable
3.12.8, did the usual "make oldconfig" (resulting config attached).

But now I noticed some _really_ low network performance."

Link: http://lkml.kernel.org/r/52DAD66F.7080306@dragonslave.de

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
