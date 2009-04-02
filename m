From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 0/9] Neterion: New driver: vxge: Resubmit #4
Date: 01 Apr 2009 20:13:47 -0800
Message-ID: <1238645626.18544.209.camel@flash>
References: <1238194418.5516.363.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33639 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762513AbZDBDdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:33:05 -0400
In-Reply-To: <1238194418.5516.363.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This series of 9 patches are a resubmission of Neterion's "vxge"
driver. We've fixed the problems observed on the sparc64, ppc64 and IA64 
plaforms. The driver has undergone a short test cycle on these platforms
as well as x86 and x86_64 systems.

A summary of changes from the last submission -
1. Fixed compilation warnings and errors on sparc64, IA64 and PPC64 - Reported
by Dave Miller.
2. Fixed aligned memory access warnings due to compare_ether_addr on sparc64.
3. Fixed sparse warning on IA64 with CONFIG_VXGE_DEBUG_TRACE_ALL enabled.
4. General clean up in patches 4, 5, 6 and 7.

Thanks,

Ram



