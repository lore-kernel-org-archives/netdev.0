From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Potential u32 classifier bug.
Date: Wed, 15 Aug 2007 11:16:09 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329036D1BDC@orsmsx414.amr.corp.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com> <20070815175758.GC32236@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC329036D1BA7@orsmsx414.amr.corp.intel.com> <20070815181139.GD32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43984 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761234AbXHOSQM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 14:16:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070815181139.GD32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 
> 2007-08-15 11:02
> > > There is this very horrible way of using the u32 
> classifier with a 
> > > negative offset to look into the ethernet header.
> > 
> > Based on this, it sounds like u32 using protocol 802_3 is broken?
> 
> You might be expecting too much from u32. The protocol given 
> to u32 is just a filter, it doesn't imply anything beyond that.
> u32 has its usage the way it is, that's way we've added an 
> ematch rather than extending u32 itself.

Ok, that clarifies it a bit.  I've just found a few examples on the net,
one of which is in a TC filter manual
(http://tcn.hypert.net/tcmanual.pdf, section 2.2.1.3 at the bottom of
the section), that was using u32 to simply filter on dest MAC address
without anything elaborate.  Either it worked way back when, or it was a
bogus example.

Thanks again Thomas,

-PJ
