From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Hidden SSID's
Date: Tue, 30 Jan 2007 14:53:13 -0800
Message-ID: <20070130225313.GG32304@instant802.com>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain> <45BD2119.2000209@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Paul Marks <pmarks@purdue.edu>
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-81.dex002.intermedia.net ([64.78.20.214]:50028 "EHLO
	dhost002-81.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751572AbXA3XHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 18:07:30 -0500
Content-Disposition: inline
In-Reply-To: <45BD2119.2000209@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 28, 2007 at 04:18:01PM -0600, Larry Finger wrote:

> Is there something funny about Cisco APs with hidden SSID?

Yes, there is.. Or well, "hidden SSID" is funny concept in itself, but
anyway.. Some APs set the SSID IE to an array of 0x00 octets with the
length of the original SSID when "hiding" the SSID while others just use
0-length SSID.

-- 
Jouni Malinen                                            PGP id EFC895FA
