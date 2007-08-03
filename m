From: Tejun Heo <teheo@suse.de>
Subject: Re: [patch 1/5][RFC] NET: Change pci_enable_device to	pci_reenable_device
 to keep device enable balance
Date: Fri, 03 Aug 2007 18:00:02 +0900
Message-ID: <46B2EE92.4080809@suse.de>
References: <20070802224423.GC5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brandon Philips <bphilips@suse.de>
To: Brandon Philips <brandon@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jericho.provo.novell.com ([137.65.248.124]:1163 "EHLO
	jericho.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930AbXHCJUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:20:33 -0400
In-Reply-To: <20070802224423.GC5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Philips wrote:
> On a slot_reset event pci_disable_device() is never called so calling
> pci_enable_device() will unbalance the enable count.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
