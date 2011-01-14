From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 09:21:41 -0800
Message-ID: <AANLkTinumTQN3F=O_hC=jFTFLKVYyWmJNNvHx2A1jL2p@mail.gmail.com>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
 <4D2FF29C.1050101@msgid.tls.msk.ru> <AANLkTikiGeSfae3guWRMp_hsh61JibacPpwGZVbgSy7h@mail.gmail.com>
 <20110114163035.GY3702@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Jarek_Kami=F1ski?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>
To: Ben Hutchings <benh@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49442 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752019Ab1ANRWD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 12:22:03 -0500
Received: from mail-iy0-f174.google.com (mail-iy0-f174.google.com [209.85.210.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p0EHM1sn027078
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 09:22:01 -0800
Received: by iyj18 with SMTP id 18so2696261iyj.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 09:22:01 -0800 (PST)
In-Reply-To: <20110114163035.GY3702@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 8:30 AM, Ben Hutchings <benh@debian.org> wrote:
>
> This is something I started to implement, but never got finished. =A0=
I
> don't think it can be done without an API change, though, as we need
> to know when to drop firmware from the cache. =A0But perhaps this cou=
ld
> be done with a hook in the device-driver binding code.

Or just associate the firmware with a module?

So if the firmware gets loaded, it stays in memory until the module is =
unloaded?

And this all would only be the case if CONFIG_PM is set, so you'd not
waste memory unnecessarily.

                Linus
