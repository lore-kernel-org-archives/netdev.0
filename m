From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 13:51:06 -0700
Message-ID: <1408049466.6804.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
	 <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53ED1516.6020801@hp.com> <53ED1CB2.7050006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43538 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbaHNUvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 16:51:08 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so2199974pde.18
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 13:51:07 -0700 (PDT)
In-Reply-To: <53ED1CB2.7050006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 13:31 -0700, Alexander Duyck wrote:

> My concern here is that netperf is a standard tool to use for testing
> network performance, and the kernel default is to run with
> tcp_low_latency disabled.  As such the prequeue is a part of the
> standard path is it not?  If the prequeue isn't really useful anymore
> should we consider pulling it out of the kernel, or disabling it by
> making tcp_low_latency the default?

Feel free to use netperf, but please do not complain if linux kernel is
not optimized for netperf, using a 20 years old application design (one
thread per flow)

prequeue only works when few TCP flows are active.

For dozen of active flows, then you probably need some tweaks,
like the ones in Documentation/networking/scaling.txt

Then, prequeue or not, you would not notice.
