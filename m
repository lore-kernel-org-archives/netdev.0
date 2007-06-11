From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 16:38:43 +0200
Message-ID: <466D5E73.8060607@trash.net>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB28BA@hasmsx412.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Cohen, Guy" <guy.cohen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44209 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbXFKOlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 10:41:12 -0400
In-Reply-To: <D0122E209EBF8D4CAB38EC6A8AF244E502AB28BA@hasmsx412.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cohen, Guy wrote:
> Patrick McHardy wrote:
> 
>>jamal wrote:
>>
>>>Sure - but what is wrong with that?
>>
>>
>>Nothing, this was just to illustrate why I disagree with the
> 
> assumption
> 
>>that the packet has hit the wire. On second thought I do agree with
> 
> your
> 
>>assumption for the single HW queue case, at the point we hand the
> 
> packet
> 
>>to the HW the packet order is determined and is unchangeable. But this
>>is not the case if the hardware includes its own scheduler. The qdisc
>>is simply not fully in charge anymore.
> 
> 
> For WiFi devices the HW often implements the scheduling, especially when
> QoS (WMM/11e/11n) is implemented. There are few traffic queues defined
> by the specs and the selection of the next queue to transmit a packet
> from, is determined in real time, just when there is a tx opportunity.
> This cannot be predicted in advance since it depends on the medium usage
> of other stations.
> 
> Hence, to make it possible for wireless devices to use the qdisc
> mechanism properly, the HW queues should _ALL_ be non-empty at all
> times, whenever data is available in the upper layers. Or in other
> words, the upper layers should not block a specific queue because of the
> usage of any other queue.


Thats exactly what I'm saying. And its not possible with a single
queue state as I tried to explain in my last last.
