From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sun, 08 Mar 2009 11:03:29 -0700
Message-ID: <49B40871.3040102@kernel.org>
References: <49B1F934.5050006@kernel.org> <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com> <86802c440903062331j22aa57c7r93c84da880a8e572@mail.gmail.com> <200903081157.37139.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:58815 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753245AbZCHSEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Mar 2009 14:04:46 -0400
In-Reply-To: <200903081157.37139.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:

>>
>> looks like second kernel can not detect the state any more.
> 
> In fact pci_enable_device() calls pci_set_power_state(dev, PCI_D0) as the first
> thing.  The question is why it doesn't work as expected.
> 
> What kernel(s) have you tested?

tip/master

also RHEL 5.3 with igb + kexec have the same problem.

YH
