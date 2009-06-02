From: =?ISO-8859-1?Q?Richard_R=3F=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Subject: Re: [PATCH] netdev: Added KS8842 driver
Date: Tue, 02 Jun 2009 21:52:58 +0200
Message-ID: <4A25831A.7010003@mocean-labs.com>
References: <4A25745E.3050402@mocean-labs.com> <20090602191122.GA5800@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:39123 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZFBTw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 15:52:58 -0400
Received: from ironport.bredband.com (195.54.101.120) by proxy3.bredband.net (7.3.140.3)
        id 49F597CD00E3D8FA for netdev@vger.kernel.org; Tue, 2 Jun 2009 21:52:59 +0200
In-Reply-To: <20090602191122.GA5800@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
>>
>> +config KS8842
>> +	tristate "Micrel KSZ8842"
>> +	depends on PCI
> Why does this driver depend on PCI ?

Good question.
The KS8842 switch is actually behind an FPGA connected via PCIe,
the next version of the FPGA firmware will have DMA support and the driver will depend on PCI.
Is it worth removing the dependency for now?


--Richard
