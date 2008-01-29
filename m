From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 15:12:05 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329046C6F62@orsmsx414.amr.corp.intel.com>
References: <20080129184726.GA29300@gateway.home> <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com> <1201640243.4431.29.camel@localhost>  <20080129214555.GC29300@gateway.home> <1201648108.4425.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>, "Erik Mouw" <mouw@nl.linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52924 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbYA2XMP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 18:12:15 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1201648108.4425.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Peter, I suspect that driver is just buggy in some other way 
> as opposed to being re-entered; couldnt tell by inspection. 
> It is possible it may be too eager to open up before it 
> really has space.
> It will be easy to check your theory by having the driver 
> just check if it is netif_stopped just before it returns 
> NETDEV_TX_BUSY.

Ahh, very good point.

Thanks,
-PJ
