From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Mon, 07 Jan 2013 09:22:42 -0800
Message-ID: <1357579362.21481.45.camel@joe-AO722>
References: <50E82D7D.4090107@asianux.com>
	 <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
	 <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>
	 (sfid-20130107_055017_668200_9F1C3EAF) <1357544828.9912.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Chen Gang <gang.chen@asianux.com>, stas.yakovlev@gmail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54166 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751607Ab3AGRWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 12:22:42 -0500
In-Reply-To: <1357544828.9912.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 08:47 +0100, Johannes Berg wrote:
> On Sun, 2013-01-06 at 20:49 -0800, Joe Perches wrote:
> > On Sun, 2013-01-06 at 19:19 -0800, Joe Perches wrote:
> > > Maybe these days this should be another vsprintf %p extension
> > > like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
> > > 
> > > (or maybe extend %ph for ssids with %*phs, length, array)
> > 
> > Maybe like this:
> 
> > + * - 'D' For a 80211 SSID, it prints the SSID escaping any non-printable
> > +         characters with a leading \ and octal or [0nrt\]
> 
> Honestly, I'm not sure it's worth it.

Neither am I really, the only value I see in it is the
reduction in stack consumption by 100 bytes or so per use.

> print_ssid() is used in two or
> three legacy drivers only, not in any modern driver, and is unlikely to
> be used in the more modern drivers due to tracing etc.

Swell.  It was just another way to correct those overrun
errors Chen Gang found.
