From: sdrb <sdrb@onet.eu>
Subject: hunging ifenslave command
Date: Thu, 18 Jun 2009 15:15:22 +0200
Message-ID: <4A3A3DEA.20602@onet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2m5.poczta.onet.pl ([213.180.138.33]:36991 "EHLO
	smtp2m5.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758047AbZFRN5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 09:57:31 -0400
Received: from ip-83-238-22-2.netia.com.pl ([83.238.22.2]:41495 "EHLO
	[192.168.242.54]" rhost-flags-OK-FAIL-OK-FAIL) by ps2.mod5.onet
	with ESMTPSA id S51170373AbZFRNPm1INdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 15:15:42 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have got problem with hunging "ifenslave" command.
I configured bond0 interfaces with 3 slaved interfaces: eth0, eth1 and 
eth2. While I'm removing one of it - sometimes only the "ifenslave" 
command hangs up but sometimes the whole system is hanging up completely 
- so it's not possible to even write on the console.

I'm using linux kernel 2.6.27.10 with bonding driver version v3.3.0 
(June 10, 2008) and ethernet card driver r8168 version 8.006.00-NAPI.

Anyone knows where is the problem with it?

sdrb
