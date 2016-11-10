From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Wed, 09 Nov 2016 20:24:52 -0500 (EST)
Message-ID: <20161109.202452.1499530038072098751.davem@davemloft.net>
References: <582190C1020000780011CF5C@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, wei.liu2@citrix.com,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754051AbcKJBYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:24:54 -0500
In-Reply-To: <582190C1020000780011CF5C@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 08 Nov 2016 00:45:53 -0700

> For single items being collected this should be preferred as being more
> typesafe (as the compiler can check format string and to-be-written-to
> variable match) and more efficient (requiring one less parameter to be
> passed).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> ---
> v3: For consistency with other code don't consider zero an error
>     (utilizing that xenbus_scanf() at present won't return zero).
> v2: Avoid commit message to continue from subject.

Applied to net-next, thanks.
