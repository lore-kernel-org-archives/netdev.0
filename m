From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Rework suspend and resume
Date: Wed, 30 Sep 2009 20:11:19 -0700 (PDT)
Message-ID: <20090930.201119.136086134.davem@davemloft.net>
References: <20090925205206.GA9270@oksana.dev.rtsoft.ru>
	<200909252354.34511.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, stern@rowland.harvard.edu,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39252
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755491AbZJADLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 23:11:00 -0400
In-Reply-To: <200909252354.34511.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Fri, 25 Sep 2009 23:54:34 +0200

> On Friday 25 September 2009, Anton Vorontsov wrote:
>> As noticed by Alan Stern, there is still one issue with the driver:
>> we disable PCI IRQ on suspend, but other devices on the same IRQ
>> line might still need the IRQ enabled to suspend properly.
>> 
>> Nowadays, PCI core handles all power management work by itself, with
>> one condition though: if we use dev_pm_ops. So, rework the driver to
>> only quiesce 3c59x internal logic on suspend, while PCI core will
>> manage PCI device power state with IRQs disabled.
>> 
>> Suggested-by: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied, thanks everyone.
