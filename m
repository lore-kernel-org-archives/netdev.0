From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bonding: Send more than one gratuitous ARP when
 slave takes over
Date: Mon, 14 Apr 2008 14:40:32 -0700 (PDT)
Message-ID: <20080414.144032.39791824.davem@davemloft.net>
References: <47FE2D2D.2040504@voltaire.com>
	<48037757.2070203@voltaire.com>
	<D5C1322C3E673F459512FB59E0DDC32904E2B512@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: monis@voltaire.com, fubar@us.ibm.com, netdev@vger.kernel.org,
	olgas@voltaire.com, ogerlitz@voltaire.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754662AbYDNVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 17:40:31 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904E2B512@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 14 Apr 2008 10:50:17 -0700

> Patch looks good to me, however I have a small nitpick below:
> 
> > +static ssize_t bonding_store_n_grat_arp(struct device *d,
> > +				    struct device_attribute *attr,
> > +				    const char *buf, size_t count)
> > +{
> > +	int new_value, ret = count;
> 
> Avoid declaring multiple variables on the same line when possible.
> Write it like this:
> 
> 	int new_value;
> 	int ret = count;
> 
> Here's a blurb from the Documentation/CodingStyle document (not gospel,
> but pretty darn close):
> 
> It's also important to comment data, whether they are basic types or
> derived
> types.  To this end, use just one data declaration per line (no commas
> for
> multiple data declarations).  This leaves you room for a small comment
> on each
> item, explaining its use.

You're telling this person to use more lines, but not telling them to
add comments, yet that is the reasoning behind the very CodingStyle
recommendation you are quoting.

I think you're recommendation is gratuitous and in my opinion wrong.
Splitting up the line adds no value, and makes the function take up
more lines on the terminal screen.
