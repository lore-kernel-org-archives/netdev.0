From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next 0/2] net: lls cleanup patches
Date: Fri, 28 Jun 2013 15:59:18 +0300
Message-ID: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37733 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967Ab3F1M7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 08:59:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here are two cleanup patches.

1. fix warning from debug_smp_processor_id().
- reported by Cody P Schafer.

2. avoid calling sched_clock() in select and poll when lls is disabled.
- reported by Andi Kleen.

Thanks to everyone for their comments.

-Eliezer
