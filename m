From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:38:32 -0800
Message-ID: <47A215A8.2090104@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu> <47A20E9E.7070503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34214 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756658AbYAaSif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:38:35 -0500
In-Reply-To: <47A20E9E.7070503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> A lot of people tend to forget that the pci-express bus has enough bandwidth on
> first glance - 2.5gbit/sec for 1gbit of traffix, but apart from data going over it
> there is significant overhead going on: each packet requires transmit, cleanup and
> buffer transactions, and there are many irq register clears per second (slow
> ioread/writes). The transactions double for TCP ack processing, and this all
> accumulates and starts to introduce latency, higher cpu utilization etc...

Sounds like tools to show PCI* bus utilization would be helpful...

rick jones
