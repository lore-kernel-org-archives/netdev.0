From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Potential u32 classifier bug.
Date: Wed, 15 Aug 2007 20:11:39 +0200
Message-ID: <20070815181139.GD32236@postel.suug.ch>
References: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com> <20070815175758.GC32236@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC329036D1BA7@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40671 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935450AbXHOSLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 14:11:21 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329036D1BA7@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2007-08-15 11:02
> > There is this very horrible way of using the u32 classifier 
> > with a negative offset to look into the ethernet header.
> 
> Based on this, it sounds like u32 using protocol 802_3 is broken?

You might be expecting too much from u32. The protocol given
to u32 is just a filter, it doesn't imply anything beyond that.
u32 has its usage the way it is, that's way we've added an ematch
rather than extending u32 itself.
