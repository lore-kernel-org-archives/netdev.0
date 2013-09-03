From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH] iproute2: linklayer interface between kernel
 and tc/userspace
Date: Tue, 3 Sep 2013 08:33:15 -0700
Message-ID: <20130903083315.1639bb0f@nehalam.linuxnetplumber.net>
References: <20130830120210.1510.80733.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60711 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab3ICPdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:33:19 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so6624378pab.27
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 08:33:19 -0700 (PDT)
In-Reply-To: <20130830120210.1510.80733.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Aug 2013 14:02:10 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> This iproute2 tc patch is connected to the kernel
>  - commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
> 
> The rate table calculated by tc, have gotten replaced in the kernel
> and is no-longer used for lookups.
> 
> This happened in kernel release v3.8 caused by kernel
>  - commit 56b765b79 ("htb: improved accuracy at high rates").
> This change unfortunately caused breakage of tc overhead and
> linklayer parameters.
> 
>  Kernel overhead handling got fixed in kernel v3.10 by
>  - commit 01cb71d2d47 (net_sched: restore "overhead xxx" handling)
> 
>  Kernel linklayer handling got fixed in kernel v3.11 by
>  - commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
> 
> The linklayer fix introduced a struct change, that allow the linklayer
> attribute to be transferred between tc and kernel. This patch make use
> of this linklayer attribute.
> 
> The linklayer setting is transfer to the kernel.  And linklayer
> setting received from the kernel is printed with a prefixed
> "linklayer" when listing current configuration.  The default
> TC_LINKLAYER_ETHERNET is only printed in detailed output mode.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Ok, Applied for 3.11
