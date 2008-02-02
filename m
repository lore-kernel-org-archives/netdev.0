From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 17:51:17 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290473814B@orsmsx414.amr.corp.intel.com>
References: <1201867609.4465.50.camel@localhost> <20080201225627.GB3071@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Andi Kleen" <andi@firstfloor.org>, "Glen Turner" <gdt@gdt.id.au>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17685 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929AbYBBBzb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 20:55:31 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080201225627.GB3071@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I totally disagree with these POVs:
> 
> - 10G cards should be treated by default as 10G cards - not 
> DSL modems,
>   and common users shouldn't have to read any warnings or configs to
>   see this.
> - tc with TBF or HTB are professional tools; there should be 
> added some
>   warnings to manuals. But trying to change the way they work because
>   we think we know better what users want, and changing BTW some other
>   things (making debugging this later a hell), is simply disrespectful
>   for target users of these tools. There are some wrappers or 
> "creators"
>   invented for this. And, BTW, I think I've seen somewhere a system
>   which does this this other way - with creators for 
> professionals. So,
>   you could be right with this too...

Ok, maybe I'm not done quite yet.  Jarek is echo'ing my original point,
changing the behavior of the tool automatically (these qdiscs in
question) is not good for a normal end user.  It might be fine for
kernel developers, but not users of these tools, IMO.  A less disruptive
approach, such as a warning message printed when loading the qdisc if
TSO is enabled, and documenting recommended usage, I think is more
prudent here.

Cheers,
-PJ Waskiewicz
