From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 07 Jun 2007 18:42:46 -0400
Message-ID: <1181256166.4071.46.camel@localhost>
References: <1181137761.4068.22.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Gagan Arneja <gaagaan@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.245]:27639 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936647AbXFGWmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:42:50 -0400
Received: by ag-out-0708.google.com with SMTP id 35so533057aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:42:49 -0700 (PDT)
In-Reply-To: <1181137761.4068.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 09:49 -0400, jamal wrote:

> If you help out, when you post your results, can you please say what
> hardware and setup was?

Ok, i have tested on new hardware with pktgen:

Machine: Dual Xeon processor with EMT64 - kernel is 32 bit.
Chipset: E7520 Memory Controller Hub (MCH). The block diagrams claim
direct connection between the MCH and PCI Express ...
Ethernet: 6 ethernet ports - e1000 82571EB.

The results are just too good i am getting worried ;->
Pktgen with plain vanilla 2.6.22-rc4 - small packets (64 B on the wire)
i.e zero changes. Avg throughput is 747Kpps
2.6.22-rc4 with batching changes as in the git tree avg throughput is
1087Kpps

That is about 45% improvement.

Note, in theory - didnt try this - you could run one ethernet port per
CPU and get equivalent improvement per CPU.

I would really really like other people to test ;->

cheers,
jamal


