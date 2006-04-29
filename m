From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] rt2x00 drivers: rt61pci
Date: Sat, 29 Apr 2006 18:10:02 +0200
Message-ID: <20060429161002.GA3345@electric-eye.fr.zoreil.com>
References: <200604291147.26887.IvDoorn@gmail.com> <20060429145850.GA2456@electric-eye.fr.zoreil.com> <200604291735.12720.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37008 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750753AbWD2QLl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 12:11:41 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604291735.12720.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ivo van Doorn <ivdoorn@gmail.com> :
[...]
> Not sure about that either. I usually choose the type of the counter
> depending on the max size of that counter.

It is not arch-neutral. powerpc favors unsigned int over int but I am
too lazy to check if the size matters.

[...]
> Perhaps, but I prefer the usage of the name "counter".
> I am not sure if there is a coding style about this? If so I could
> rename "counter" to "i".

Chapter 4 of Documentation/CodingStyle goes in this direction.
The document is not meant to be a taken too literally though.

The repetitive use of 'counter' + foo[counter].blah tends to be a
bit bloaty.

[...]
> I'll create a bugreport in the rt2x00 project bugzilla
> with some of the coding style change requests.

I will not complain if you open a bugreport to provide a git repo
as well.

/me hides...

-- 
Ueimor
