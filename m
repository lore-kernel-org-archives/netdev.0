From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [PATCH 8/8] x25: use limited socket backlog
Date: Wed, 3 Mar 2010 22:00:32 +0800
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860A45A6992@shzsmsx502.ccr.corp.intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
	 <1267600109.2839.101.camel@edumazet-laptop>
 <d45a3acc1003030338m3102a95p1b06b7db1b24e58e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: andrew hendry <andrew.hendry@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23493 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754190Ab0CCOAi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:00:38 -0500
In-Reply-To: <d45a3acc1003030338m3102a95p1b06b7db1b24e58e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

andrew hendry <andrew.hendry@gmail.com> wrote:

> Will wait for the next spin and in the meantime think if there is way
> to test it. x25 with no loopback and being so slow probably cant generate the same
> as your UDP case.

I didn't find a way to drop the packet correctly. So I didn't change any behavior in
this patch. Nor did I do in the second spin. It will be fine if you also think x25 doesn't
need to limit its backlog size.

Thanks,
-yi

