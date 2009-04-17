From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Fri, 17 Apr 2009 08:15:44 +0800
Message-ID: <b6a2187b0904161715s46412569t4aa9b255427f9626@mail.gmail.com>
References: <20090415170111.6e1ca264@nehalam>
	 <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	 <49E72E83.50702@trash.net>
	 <20090416.153354.170676392.davem@davemloft.net>
	 <20090416234955.GL6924@linux.vnet.ibm.com>
	 <20090416165233.5d8bbfb5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, torvalds@linux-foundation.org,
	dada1@cosmosbay.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:59669 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbZDQAPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 20:15:45 -0400
In-Reply-To: <20090416165233.5d8bbfb5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 7:52 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> recursive lock that can be nested. It is sort of like existing kernel_lock,
> rwlock_t and even old 2.4 brlock.

Tested and working. As fast as before.

Thanks,
Jeff.
