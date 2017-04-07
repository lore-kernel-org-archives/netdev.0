From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qede: support XDP head adjustments
Date: Fri, 07 Apr 2017 06:28:23 -0700 (PDT)
Message-ID: <20170407.062823.211099471945970970.davem@davemloft.net>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755164AbdDGN2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:28:25 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Fri, 7 Apr 2017 11:04:56 +0300

> Daniel has brought to my attention the fact that qede is the only driver
> that currently supports XDP but still fails any program where
> xdp_adjust_head is set on the bpf_prog. This series is meant to remedy
> this and align qede with the rest of the driver, making it possible to
> remove said field.
> 
> Patch #1 contains a minor cache-saving optimization for latter patches.
> 
> Patches #2 & #3 address existing issues with the qede implementation
> [#2 should have been a part of this as it addresses something that's
> affected by the additional headroom; #3 is simply here for the ride].
> 
> Patches #4 & #5 add the necessary logic in driver for ingress headroom,
> the first adding the infrastrucutre needed for supporting the headroon
> [as currently qede doesn't support such], and the second removing the
> existing XDP limitation.

Series applied, thanks for fleshing out the full XDP support matrix in
this driver.  I think it is very important for all devices supporting
XDP to support the entire suite of XDP facilities.
