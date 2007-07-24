From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2][RFC] Update net core to use devres.
Date: Tue, 24 Jul 2007 16:42:40 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903483FB4@orsmsx414.amr.corp.intel.com>
References: <11853167964115-git-send-email-bphilips@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <bphilips@suse.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62568 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441AbXGXXnh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 19:43:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <11853167964115-git-send-email-bphilips@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * netdev_pci_remove_one() can replace simple pci device remove
>   functions
> 
> * devm_alloc_netdev() is like alloc_netdev but allocates 
> memory using devres.
>   alloc_netdev() can be removed once all drivers use devres.

Please look at the multiqueue network code that is in 2.6.23.  It
creates alloc_netdev_mq() for multiqueue network device drivers.  If you
want to add this devres feature (which based on the threads, might be
difficult), please make sure you comprehend the multiqueue features.

Thanks,

-PJ Waskiewicz
