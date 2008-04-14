From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] net/bonding: Send more than one gratuitous ARP when slave takes over
Date: Mon, 14 Apr 2008 10:50:17 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904E2B512@orsmsx414.amr.corp.intel.com>
References: <47FE2D2D.2040504@voltaire.com> <48037757.2070203@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"Olga Stern" <olgas@voltaire.com>,
	"Or Gerlitz" <ogerlitz@voltaire.com>
To: <monis@voltaire.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56919 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755602AbYDNRui convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 13:50:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48037757.2070203@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch looks good to me, however I have a small nitpick below:

> +static ssize_t bonding_store_n_grat_arp(struct device *d,
> +				    struct device_attribute *attr,
> +				    const char *buf, size_t count)
> +{
> +	int new_value, ret = count;

Avoid declaring multiple variables on the same line when possible.
Write it like this:

	int new_value;
	int ret = count;

Here's a blurb from the Documentation/CodingStyle document (not gospel,
but pretty darn close):

It's also important to comment data, whether they are basic types or
derived
types.  To this end, use just one data declaration per line (no commas
for
multiple data declarations).  This leaves you room for a small comment
on each
item, explaining its use.


Cheers,
-PJ Waskiewicz
