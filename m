From: Glen Turner <gdt@gdt.id.au>
Subject: DF Bit set on UDP traffic -- bug or feature?
Date: Thu, 20 Aug 2009 09:22:45 +1000
Message-ID: <4A8C8945.70602@gdt.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:44460 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753253AbZHTAAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 20:00:33 -0400
Received: from thrace.aarnet.edu.au ([202.158.213.132])
	(authenticated bits=0)
	by aix.gdt.id.au (8.14.2/8.14.2) with ESMTP id n7JNMkPB004033
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 08:52:48 +0930
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Is it a bug that the DF bit is set on UDP traffic when TCP Path
MTU Discovery is active, but yet when a returning ICMP DF Set But
Fragmentation Required response is received the kernel does not
attempt fragmentation of the outgoing UDP-carrying IP packets?

This has practical consequences for large RADIUS packets, such
as in the RADIUS/TLS/UDP protocol "DTLS".  They are not fragmented
by the network and they are not fragmented by the kernel, and thus
the packets fail to pass from the application to the end-user.

Can I humbly suggest that when the kernel does not implement
its own fragmentation strategy (as it does with TCP Path MTU
Discovery) that the DF bit not be set by the kernel?

Thanks very much, Glen

-- 
  Glen Turner, Network Engineer, Australia's Academic & Research Network
  www.aarnet.edu.au
  +61 8 8303 3936
