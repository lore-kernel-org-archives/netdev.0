From: Patrick McHardy <kaber@trash.net>
Subject: Re: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 19:28:47 +0200
Message-ID: <46A7884F.70707@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329034BF7D3@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55535 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934368AbXGYR3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 13:29:45 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329034BF7D3@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>The protocol match is on skb->protocol, so it case of 
>>ethernet its on the ethernet protocol, which is ETH_P_IP or 
>>"ip" for IPv4.
> 
> 
> I see that in the code, but the reason I started worrying was when I
> added the 802_3 classifier on 8 flows, it would shove all traffic into
> flowid 1:1, no matter if it matched or not.
> 
> I'll keep investigating and see if I can narrow down what I'm seeing.


I'm not sure what you're expecting. skb->protocol is usually not set
to ETH_P_802_3, which is why the filter is not matching.
