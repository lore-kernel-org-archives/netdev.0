From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Potential u32 classifier bug.
Date: Wed, 15 Aug 2007 19:57:58 +0200
Message-ID: <20070815175758.GC32236@postel.suug.ch>
References: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40642 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758331AbXHOR5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 13:57:37 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2007-08-09 18:07
> My big question is: Has anyone recently used the 802_3 protocol in tc
> with u32 and actually gotten it to work?  I can't see how the
> u32_classify() code can look at the mac header, since it is using the
> network header accessor to start looking.  I think this is an issue with
> the classification code, but I'm looking to see if I'm doing something
> stupid before I really start digging into this mess.

There is this very horrible way of using the u32 classifier with a
negative offset to look into the ethernet header.

You might want to look into the cmp ematch which can be attached to
almost any classifier. It allows basing offsets on any layer thus
making ethernet header filtering trivial.
