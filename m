From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] pktgen: Clone skb to avoid corruption of skbs in	ndo_start_xmit methods
Date: Wed, 20 Jul 2011 11:23:54 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B912AC4070@nsmail.netscout.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>	<1311105738.3113.11.camel@edumazet-laptop>	<20110719202922.GA2352@minipsycho>	<1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org> <4E26205C.1040106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Jiri Pirko" <jpirko@redhat.com>, <netdev@vger.kernel.org>,
	"Alexey Dobriyan" <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Rick Jones" <rick.jones2@hp.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og111.obsmtp.com ([64.18.1.27]:44993 "HELO
	exprod6og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751302Ab1GTPX5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:23:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4E26205C.1040106@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Rick Jones
> Sent: July 19, 2011 8:25 PM
> To: Neil Horman
> Cc: Eric Dumazet; Jiri Pirko; netdev@vger.kernel.org; Alexey Dobriyan;
> David S. Miller
> Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
> ndo_start_xmit methods
> 
> How "everyday use" is pktgen considered?  As "everyday use" as
> netperf/iperf/whatnot? Is it actually considered something one would
> run
> on production rather than test systems?
> 

Totally agree. There are quite a few ways to send traffic from
user-space. Build a pcap file and then blast it from user-space. No sane
sysadmin would use pktgen on production systems to begin with.




