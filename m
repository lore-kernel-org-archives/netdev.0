From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 15:42:54 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290133D2A0@orsmsx414.amr.corp.intel.com>
References: <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700F27@orsmsx414.amr.corp.intel.com> <20080131231045.GA5543@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andi Kleen" <andi@firstfloor.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47597 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756184AbYAaXrq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 18:47:46 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, it could be just that when using such qdiscs TSO would be
> disabled, but the user could override this by using ethtool after
> loading the qdiscs.

I still disagree with this.  The qdisc should not cause anything to happen to feature flags on the device. It's the scheduling layer and really shouldn't care about what features the device supports or not.  If someone has an issue with a feature hurting performance or causing odd behavior when using a qdisc, then they should disable the feature on the device using the appropriate tools provided.  If it's the qdisc causing issues, then either the qdisc needs to be fixed, or it should be documented what features are recommended to be on and off with the qdisc.  I don't agree that the scheduling layer should affect features on an underlying device.

Cheers,

-PJ Waskiewicz
