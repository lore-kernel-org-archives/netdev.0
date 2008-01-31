From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:47:42 -0800
Message-ID: <47A217CE.4000002@intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu> <47A20E9E.7070503@intel.com> <47A215A8.2090104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55628 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758160AbYAaSu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 13:50:58 -0500
In-Reply-To: <47A215A8.2090104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
>> A lot of people tend to forget that the pci-express bus has enough
>> bandwidth on
>> first glance - 2.5gbit/sec for 1gbit of traffix, but apart from data
>> going over it
>> there is significant overhead going on: each packet requires transmit,
>> cleanup and
>> buffer transactions, and there are many irq register clears per second
>> (slow
>> ioread/writes). The transactions double for TCP ack processing, and
>> this all
>> accumulates and starts to introduce latency, higher cpu utilization
>> etc...
> 
> Sounds like tools to show PCI* bus utilization would be helpful...

that would be a hardware profiling thing and highly dependent on the part sticking
out of the slot, vendor bus implementation etc... Perhaps Intel has some tools for
this already but I personally do not know of any :/

Auke
