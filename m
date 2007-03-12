From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Mon, 12 Mar 2007 10:21:49 -0800
Message-ID: <20070312182149.GA1785@devicescape.com>
References: <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173393326.3831.21.camel@johannes.berg> <20070309213531.GA28070@bougret.hpl.hp.com> <1173634801.3382.8.camel@johannes.berg> <20070312175639.GA4048@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-44.dex002.intermedia.net ([64.78.21.135]:49600 "EHLO
	dhost002-44.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbXCLSWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:22:03 -0400
Content-Disposition: inline
In-Reply-To: <20070312175639.GA4048@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 10:56:39AM -0700, Jean Tourrilhes wrote:

> > I would guess that others "use" iwlib like that too.
> 
> 	Which others ? The applications that process scan results can
> be counted on your fingers. And if you count the one actively
> developped, you can use one hand.

Quick search of SIOCGIWSCAN with Google Code Search
(http://www.google.com/codesearch) shows quite large set of uses. Most
of them are from various drivers, but at least some (e.g., Xsupplicant,
waproamd) are from user space applications. I did not actually verify
whether any of these would be affected by the 64/32-bit issue, but I
would assume some of the apps are indeed parsing the scan results with
internal implementation.

-- 
Jouni Malinen                                            PGP id EFC895FA
