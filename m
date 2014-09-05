From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: Add function for parsing the header
 length out of linear ethernet frames
Date: Fri, 5 Sep 2014 13:02:19 -0700
Message-ID: <CAADnVQKNoOdSuuQ-voKVNpke-4BjvC_pU=g65=m70Y4TsTpTag@mail.gmail.com>
References: <20140905180642.730.22292.stgit@ahduyck-bv4.jf.intel.com>
	<20140905180951.730.86041.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:42605 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaIEUCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 16:02:20 -0400
Received: by mail-qc0-f177.google.com with SMTP id i8so12505399qcq.8
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 13:02:19 -0700 (PDT)
In-Reply-To: <20140905180951.730.86041.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 11:10 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> This patch updates some of the flow_dissector api so that it can be used to
> parse the length of ethernet buffers stored in fragments.  Most of the
> changes needed were to __skb_get_poff as it needed to be updated to support
> sending a linear buffer instead of a skb.
>
>
>  u32 __skb_get_poff(const struct sk_buff *skb);
> +u32 ___skb_get_poff(const struct sk_buff *skb, void *data,
> +                   const struct flow_keys *keys, int hlen);

three underscores and not a static function?
May be we need to come with a proper name for it.
Two easy to confuse with two underscore version...
