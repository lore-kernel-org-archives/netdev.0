From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Any ideas about a crash on reboot with igb and intel_iommu?
Date: Thu, 01 Apr 2010 15:45:01 -0700
Message-ID: <ada39zeg5ci.fsf@roland-alpha.cisco.com>
References: <adabpe3f3c4.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: iommu@lists.linux-foundation.org,
	David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:6169 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab0DAWpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 18:45:04 -0400
In-Reply-To: <adabpe3f3c4.fsf@roland-alpha.cisco.com> (Roland Dreier's message
	of "Thu, 01 Apr 2010 11:13:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > One other data point is that enabling the BIOS option "maximize memory
 > under 4GB" (which apparently just allocates less space for PCI BARs
 > below 4GB) seems to make this crash go away again.

Never mind about this, apparently the crashes do actually happen even
after changing the BIOS config.
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
