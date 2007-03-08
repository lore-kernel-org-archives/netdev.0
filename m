From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 8 Mar 2007 11:34:12 -0800
Message-ID: <20070308193412.GG23040@devicescape.com>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, Michael Buesch <mb@bu3sch.de>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>, Dan Williams <dcbw@redhat.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-63.dex002.intermedia.net ([64.78.20.12]:50620 "EHLO
	dhost002-63.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933189AbXCHTeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 14:34:18 -0500
Content-Disposition: inline
In-Reply-To: <1173382042.3248.63.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 08:27:22PM +0100, Johannes Berg wrote:
> On Thu, 2007-03-08 at 10:49 -0800, Jean Tourrilhes wrote:
> > 	A proper fix would involve forcing the alignement in the
> > kernel. Unfortunately, that would break 64bit->64bit configs. I think
> > I can build a workaround for this in iwlib.
> 
> Actually, other tools like network manager, wpa supplicant and possibly
> more don't use iwlib afaik and are affected too, so the only real fix
> seems to be possible in the kernel.

Yes, workaround in just iwlib is not enough. If the only possible
solution is user space workaround, it better be documented (and
communicated to maintainers of user space apps) well so that
all user space programs not using iwlib can be modified, too.

-- 
Jouni Malinen                                            PGP id EFC895FA
