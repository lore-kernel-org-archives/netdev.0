From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: RE: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked
 by higher protocol
Date: Tue, 14 Jul 2015 11:52:13 +0000
Message-ID: <3167EFAB95044A4EB6B134B9A39AA98A055B60A2@xmb-rcd-x05.cisco.com>
References: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
 <20150714110501.GC25674@breakpoint.cc>
 <3167EFAB95044A4EB6B134B9A39AA98A055B5E50@xmb-rcd-x05.cisco.com>
 <20150714113531.GD25674@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-7.cisco.com ([173.37.86.78]:35003 "EHLO
	rcdn-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGNLwO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:52:14 -0400
Received: from xhc-aln-x08.cisco.com (xhc-aln-x08.cisco.com [173.36.12.82])
	by alln-core-4.cisco.com (8.14.5/8.14.5) with ESMTP id t6EBqEcM011514
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:52:14 GMT
In-Reply-To: <20150714113531.GD25674@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal [mailto:fw@strlen.de] wrote:
> Maybe, but if you broute everything you might as well just remove the
> bridge...
I want to be selective. My setup is a home router. So I can have ebtables rules for 
which traffic to (b)route and which to bridge, based on security/performance criteria.

> You can use -j redirect in ebtables broute table to force local MAC dnat
> (this also 'fixes' the pkttype to _HOST) if you really want to broute.
I may be missing something obvious, but what is the normal case where using an 
ebtables 'broute' "-j DROP" rule does work? It seemed to me that without the 
fix all (b)routed packets would get lost in IP layer
(unless also dnat or something is done in addition which changes the pkt_type value). 
What is the original intention of this table/chain if not pulling packets between 
"other hosts" out of the bridge and passing them through the IP and higher layers?
