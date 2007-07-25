From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 10:24:01 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034BF7D3@orsmsx414.amr.corp.intel.com>
References: <46A699E3.2000609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8781 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763197AbXGYRY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 13:24:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A699E3.2000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The protocol match is on skb->protocol, so it case of 
> ethernet its on the ethernet protocol, which is ETH_P_IP or 
> "ip" for IPv4.

I see that in the code, but the reason I started worrying was when I
added the 802_3 classifier on 8 flows, it would shove all traffic into
flowid 1:1, no matter if it matched or not.

I'll keep investigating and see if I can narrow down what I'm seeing.

Thanks Patrick,
-PJ
