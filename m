From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: tcpdump's capture filter: "vlan" doesn't match
Date: Fri, 17 Oct 2014 01:25:17 +0200
Message-ID: <DUB123-W25C5DA9BEDC92CD2524B68EDAB0@phx.gbl>
References: <DUB123-W23D5ECAD4869F9A799E1F6EDAA0@phx.gbl>,<543F616C.5040801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?iso-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Jesse Gross <jesse@nicira.com>,
	Michael Richardson <mcr@sandelman.ca>,
	Ani Sinha <ani@aristanetworks.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc1s11.hotmail.com ([157.55.0.210]:50691 "EHLO
	DUB004-OMC1S11.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbaJPXZY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 19:25:24 -0400
In-Reply-To: <543F616C.5040801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Isn't disabling rx-vlan-offloading supposed to remedy those problems?
>
> There were some discussions on this in the past e.g. [1]. We have
> SKF_AD_VLAN_TAG and SKF_AD_VLAN_TAG_PRESENT for the BPF filter on
> this, but libpcap is currently not making use of any of them.
>
> [1] http://thread.gmane.org/gmane.linux.network/247947

Thanks for the link. I see the situation is unfortunate and although those
new BPF filters in the kernel may fix the actual filtering problem, one
thing seems to remain impossible: disabling all this kernel magic and
passing the frame as-is to libpcap without interception (avoiding any
kind of artificial header reconstruction).

How is the situation with netsniff-ng anyway? Does it use vlan BPF filter
in the kernel?



Regards,

Lukas

 		 	   		  