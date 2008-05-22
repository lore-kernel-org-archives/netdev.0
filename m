From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Thu, 22 May 2008 11:57:43 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051F37E3@orsmsx414.amr.corp.intel.com>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au> <48344DAA.4060107@trash.net> <20080521233952.GA27138@gondor.apana.org.au> <D5C1322C3E673F459512FB59E0DDC329051F36F5@orsmsx414.amr.corp.intel.com> <4835B556.4020308@trash.net> <D5C1322C3E673F459512FB59E0DDC329051F3761@orsmsx414.amr.corp.intel.com> <4835BA86.8010209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:52381 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbYEVS5v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:57:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4835BA86.8010209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The idea is simply to replace the NETIF_F_VLAN_TSO and 
> checksumming flag by a flag mask that specifies the features 
> that may be propagated to the VLAN devices.
> 
> The change to your driver will most likely be something like:
> 
> - dev->features |= NETIF_F_VLAN_TSO | ...
> + dev->vlan_features |= NETIF_F_TSO | NETIF_F_TSO6 | 
> NETIF_F_CSUM_ALL | ...
> 
> I'll send the patch tommorrow, I'm currently busy with other things.

Ok.  That sounds great.  Thanks Patrick.

-PJ Waskiewicz
