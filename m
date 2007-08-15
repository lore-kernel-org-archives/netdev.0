From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Potential u32 classifier bug.
Date: Wed, 15 Aug 2007 11:02:00 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329036D1BA7@orsmsx414.amr.corp.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com> <20070815175758.GC32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34762 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753973AbXHOSCD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 14:02:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070815175758.GC32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 
> 2007-08-09 18:07
> > My big question is: Has anyone recently used the 802_3 
> protocol in tc 
> > with u32 and actually gotten it to work?  I can't see how the
> > u32_classify() code can look at the mac header, since it is 
> using the 
> > network header accessor to start looking.  I think this is an issue 
> > with the classification code, but I'm looking to see if I'm doing 
> > something stupid before I really start digging into this mess.
> 
> There is this very horrible way of using the u32 classifier 
> with a negative offset to look into the ethernet header.

Based on this, it sounds like u32 using protocol 802_3 is broken?

> You might want to look into the cmp ematch which can be 
> attached to almost any classifier. It allows basing offsets 
> on any layer thus making ethernet header filtering trivial.

I'll look at this.  Thanks Thomas for the response!

-PJ
