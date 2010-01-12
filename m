From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Tue, 12 Jan 2010 12:19:44 +0100
Message-ID: <1263295184.6037.26.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:42993 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab0ALLTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 06:19:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-12 at 01:30 +0100, David Miller wrote:

> From: frank.blaschka@de.ibm.com
> Date: Mon, 11 Jan 2010 13:50:50 +0100
>
> > From: Ursula Braun <ursula.braun@de.ibm.com>
> > 
> > New feature to trace HiperSockets network traffic for debugging
> > purposes.
> > 
> > Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> > Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

> How exactly does this work?

Dave,

HiperSockets provides internal "virtual" Local Area Networks within a
System z server for communication between different virtual servers
running on one System z server.
The HiperSockets Network Traffic Analyzer (HS NTA) is a function
available with System z10. It traces messages from and to devices within
the same HiperSockets LAN the NTA device belongs to, if the
participating LPARs are authorized for sniffing at the SE (Support
Element of a System z server).
An HS NTA device in Linux on System z is a specialized HiperSockets
device managed by the qeth driver and initialized specifically for
sniffing. The trigger for an HS device to act as a Network Traffic
Analyzer is the sysfs attribute "sniffer". If this attribute is set to
1, the NTA-specific initialization is started when the HS device is
brought online. Traffic sniffing starts, once the device is switched
into promiscuous mode, for instance by invoking the tcpdump-tool.

Regards, Ursula Braun

