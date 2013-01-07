From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Mon, 07 Jan 2013 08:47:08 +0100
Message-ID: <1357544828.9912.0.camel@jlt4.sipsolutions.net>
References: <50E82D7D.4090107@asianux.com>
	 <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
	 <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>
	 (sfid-20130107_055017_668200_9F1C3EAF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Chen Gang <gang.chen@asianux.com>, stas.yakovlev@gmail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34130 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab3AGHq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 02:46:56 -0500
In-Reply-To: <1357534195.21481.31.camel@joe-AO722> (sfid-20130107_055017_668200_9F1C3EAF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 20:49 -0800, Joe Perches wrote:
> On Sun, 2013-01-06 at 19:19 -0800, Joe Perches wrote:
> > Maybe these days this should be another vsprintf %p extension
> > like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
> > 
> > (or maybe extend %ph for ssids with %*phs, length, array)
> 
> Maybe like this:

> + * - 'D' For a 80211 SSID, it prints the SSID escaping any non-printable
> +         characters with a leading \ and octal or [0nrt\]

Honestly, I'm not sure it's worth it. print_ssid() is used in two or
three legacy drivers only, not in any modern driver, and is unlikely to
be used in the more modern drivers due to tracing etc.

johannes
