From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next-2.6 PATCH 3/3] net: consolidate 8021q tagging
Date: Wed, 3 Nov 2010 17:47:00 -0700
Message-ID: <AANLkTi=RnnXNFufYgBi56h6eJENNBi1VuHB3oBxy50Wc@mail.gmail.com>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
	<20101031002242.8691.38060.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59918 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab0KDArB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 20:47:01 -0400
Received: by mail-ww0-f44.google.com with SMTP id 13so70446wwb.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 17:47:00 -0700 (PDT)
In-Reply-To: <20101031002242.8691.38060.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 30, 2010 at 5:22 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> Now that VLAN packets are tagged in dev_hard_start_xmit()
> at the bottom of the stack we no longer need to tag them
> in the 8021Q module (Except in the !VLAN_FLAG_REORDER_HDR
> case).
>
> This allows the accel path and non accel paths to be consolidated.
> Here the vlan_tci in the skb is always set and we allow the
> stack to add the actual tag in dev_hard_start_xmit().
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jesse Gross <jesse@nicira.com>

Thanks John.
