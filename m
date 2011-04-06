From: David Miller <davem@davemloft.net>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 12:12:08 -0700 (PDT)
Message-ID: <20110406.121208.189703414.davem@davemloft.net>
References: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fedora-kernel-list@redhat.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: jesse.brandeburg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756559Ab1DFTMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:12:45 -0400
In-Reply-To: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Date: Wed, 6 Apr 2011 11:51:06 -0700

> perf showed netfilter being prominent, and removing it gives me much
> higher throughput.  Is there a reason CONFIG_NETFILTER=y ?  Isn't it a
> good thing to be able to disable netfilter if you want to?

CONFIG_NETFILTER=y is the only possible non-disabled setting, as it's
a boolean.

All that is enabling is the hooks, and it's not possible to provide
netfilter at all without the hooks being compiled into the kernel
image.

Fedora by default is also probably installing several defauly
netfilter rules, make sure to remove them.
