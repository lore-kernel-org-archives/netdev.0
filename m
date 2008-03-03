From: Rick Jones <rick.jones2@hp.com>
Subject: Re: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 11:38:49 -0800
Message-ID: <47CC53C9.1000400@hp.com>
References: <47CC0920.6000005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:24960 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233AbYCCTix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:38:53 -0500
In-Reply-To: <47CC0920.6000005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Hi,
> 
> Some performance tests was made by Benjamin to watch out the impact of 
> the network namespace. The good news is there is no impact when used 
> with or without namespaces. That has been checked using a real network 
> device inside a network namespace.

The *_RR tests seem to show a drop in througput and corresponding 
increases in service demand - could that be because things like TSO et 
al cannot mask much of anything in the way of a path-length increase?

 From the annotations, I'm ass-u-me-ing that NS was only used on the 
netperf side and not both netperf and netserver side?

happy benchmarking,

rick jones

> These results are consistent with the ones previously made for ipv4.
> 
> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
> 
> Thanks to Benjamin who did all the performance tests :)
> 
