From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Wed, 08 Apr 2015 11:19:02 -0700
Message-ID: <55257116.30300@hp.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr> <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr> <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr> <5525634A.10207@hp.com> <alpine.LSU.2.20.1504081938320.14413@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:57713 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbbDHSTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 14:19:05 -0400
In-Reply-To: <alpine.LSU.2.20.1504081938320.14413@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 11:16 AM, Jan Engelhardt wrote:

> One more thing to be aware of is that iptraf counts all the
> headers, which netperf likely is not doing.
>
>   -m   1: iptraf  57 MBit/s, netperf   0.69*10^6
>   -m  10: iptraf  63 MBit/s, netperf   6.76*10^6
>   -m 100: iptraf 114 MBit/s, netperf  75.74*10^6
> <no -m>: iptraf~580 MBit/s, netperf 542.00*10^6

Indeed, netperf makes no attempt to count headers.  What it reports is 
strictly above the socket interface.

rick
