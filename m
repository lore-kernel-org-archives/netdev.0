From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 6 Apr 2011 16:57:19 -0300
Message-ID: <20110406195719.GE14697@ghostprotocols.net>
References: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com> <20110406.121208.189703414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@gmail.com, fedora-kernel-list@redhat.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44328 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756705Ab1DFT51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:57:27 -0400
Received: by gyd10 with SMTP id 10so713346gyd.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 12:57:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110406.121208.189703414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Apr 06, 2011 at 12:12:08PM -0700, David Miller escreveu:
> From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
> Date: Wed, 6 Apr 2011 11:51:06 -0700
> > perf showed netfilter being prominent, and removing it gives me much
> > higher throughput.  Is there a reason CONFIG_NETFILTER=y ?  Isn't it a
> > good thing to be able to disable netfilter if you want to?
> 
> CONFIG_NETFILTER=y is the only possible non-disabled setting, as it's
> a boolean.
> 
> All that is enabling is the hooks, and it's not possible to provide
> netfilter at all without the hooks being compiled into the kernel
> image.
> 
> Fedora by default is also probably installing several defauly
> netfilter rules, make sure to remove them.

Was there ever any attempt to try to have netfilter built-in but not
causing the performance impact?

Something like ftrace code changing when the user inserts the first
rule?

People wanting top performance disable it in the build, but thos wanting
to stick to vendor provided kernels don't have that choice :)

- Arnaldo
