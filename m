From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Tue, 29 Aug 2006 10:55:44 -0700
Message-ID: <20060829175544.GI1701@instant802.com>
References: <44F356DF.9000000@linux.intel.com> <200608281417.39948.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-75.dex002.intermedia.net ([64.78.20.105]:21359 "EHLO
	DHOST002-75.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965193AbWH2R7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 13:59:11 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200608281417.39948.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 02:17:34PM -0700, Michael Wu wrote:

> It would be helpful if you inlined your patches instead of attaching them next 
> time.

Agreed.

> I'm not comfortable with using the name for this purpose.

And agreed. wireless.h has this to say about SIOCGIWNAME:

#define SIOCGIWNAME     0x8B01          /* get name == wireless protocol */
/* SIOCGIWNAME is used to verify the presence of Wireless Extensions.
 * Common values : "IEEE 802.11-DS", "IEEE 802.11-FH", "IEEE 802.11b"...
 * Don't put the name of your driver there, it's useless. */


The proposed use here is against this and should not be applied.
SIOCGIWAP can be used to indicate association status and SIOCGIWTXPOW
can be used to indicate whether TX is powered which is quite close to
radio off indication.

-- 
Jouni Malinen                                            PGP id EFC895FA
