From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myri10ge: improve port type reporting in ethtool output
Date: Mon, 19 Oct 2009 08:34:00 -0400
Message-ID: <4ADC5CB8.4010801@myri.com>
References: <4ADBFA88.8030300@myri.com> <1255939929.3916.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1815 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755572AbZJSNKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 09:10:52 -0400
In-Reply-To: <1255939929.3916.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:

> Lying about link modes is not an improvement.

OK, so we're probably doing something wrong. I suspect we're not
alone.  At least we don't set SUPPORTED_TP for CX4, like I've
seen some NICs do.

Can somebody suggest how we can tell ethtool that
the NIC supports 10Gb only (no autoneg down to 1Gb or lower)
for copper (10Gbase-CX4)?   How about for fiber (10Gbase-{S,L})R?



Thanks,

Drew
