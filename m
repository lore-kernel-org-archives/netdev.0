From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] wext: fix an ancient bug
Date: Wed, 14 Jun 2017 15:35:36 -0400 (EDT)
Message-ID: <20170614.153536.450859354383251394.davem@davemloft.net>
References: <20170614115523.16379-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        robert@ocallahan.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751665AbdFNTfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:35:43 -0400
In-Reply-To: <20170614115523.16379-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 14 Jun 2017 13:55:20 +0200

> Robert O'Callahan reported that since struct iwreq is smaller than
> struct ifreq, if it happens to land at the end of a mapped section
> userspace will erroneously get -EFAULT.
> 
> Bug report is https://bugzilla.kernel.org/show_bug.cgi?id=195869.
> 
> This bug is ancient, it kernel 2.1.15 was the first to contain the
> bug, and was released almost exactly 20.5 years ago.
> 
> Dave, I don't know if we should even bother sending this to stable,
> but if so, the third patch will apply by itself but not compile, a
> smaller patch consist of only the net/core/dev_ioctl.c modifications
> with a cast thrown in where the compile fails/warns due to passing
> the wrong struct type.
> 
> Should I merge this through my tree?

Agreed that -stable is probably not appropriate, and yes feel free to
merge it via your tree.

20.5 years... makes me feel old :-)
