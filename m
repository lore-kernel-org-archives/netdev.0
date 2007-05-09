From: Andi Kleen <andi@firstfloor.org>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: 09 May 2007 12:35:29 +0200
Message-ID: <p733b26waha.fsf@bingen.suse.de>
References: <463F91D3.3010000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48715 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141AbXEIJiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 05:38:05 -0400
In-Reply-To: <463F91D3.3010000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

> Folks -
> 
> Is it a bug, or a feature that after changing a device's smp_affinity
> via echo "N" >> /proc/irq/M/smp_affinity that the new mask isn't
> visible via cat /proc/irq/M/smp_affinity until after actual interrupts
> are taken?

Intel chipsets can only safely update affinity during interrupt processing.
You see a side effect of the code implementing this restriction.

-Andi
