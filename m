From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro X7DB3
Date: Wed, 08 Oct 2008 12:29:22 +0200
Message-ID: <m33aj78jnh.fsf@maximus.localdomain>
References: <48EB7161.60004@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bruce.w.allan@intel.com
To: "Hillier\, Gernot" <gernot.hillier@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58824 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbYJHK3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 06:29:24 -0400
In-Reply-To: <48EB7161.60004@siemens.com> (Gernot Hillier's message of "Tue\, 07 Oct 2008 16\:25\:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

"Hillier, Gernot" <gernot.hillier@siemens.com> writes:

> On at least two machines using the Supermicro X7DB3 board with Intel
> 82563EB (a.k.a. PCI device 8086:1096), we see sporadic problems on modprobe
> (about 1 time in some hundred tries):
>
> e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> e1000e 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> e1000e 0000:06:00.0: setting latency timer to 64
> 0000:06:00.0: 0000:06:00.0: Hardware Error

What does "lspci -vv" say about it when the above happens?

I spurious chip reset (hardware) could probably cause that.
-- 
Krzysztof Halasa
