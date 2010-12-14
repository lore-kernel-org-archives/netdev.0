From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Tue, 14 Dec 2010 13:10:15 +0000
Message-ID: <1292332218.15586.49.camel@i7.infradead.org>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Pierre Ossman <pierre-list@ossman.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:36107 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755981Ab0LNNKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 08:10:25 -0500
In-Reply-To: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-12 at 14:43 +0100, Pierre Ossman wrote:
> RFC 6106 specifies a new RA option for DNS resolver configuration that
> therefore needs to end up in userspace.
> 
> This first patch just exports the new option, but I started thinking
> that this seems overly complex that the kernel needs to be updated
> every time there is something new of interest to userspace in the RA.
> So I also have a second patch that exports everything that the kernel
> doesn't want.
> 
> Patches only compile tested so far as I'm still hacking away at
> userspace. Comments very much welcome though.

Totally untested userspace support:
http://git.infradead.org/users/dwmw2/connman.git

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

