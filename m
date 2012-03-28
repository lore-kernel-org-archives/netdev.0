From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V3 0/6] net/mlx4_en: DCB QoS support
Date: Thu, 29 Mar 2012 00:21:57 +0200
Message-ID: <CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
References: <1332860951-23042-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:32795 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758757Ab2C1WV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 18:21:59 -0400
Received: by lahj13 with SMTP id j13so1712567lah.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 15:21:57 -0700 (PDT)
In-Reply-To: <1332860951-23042-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 5:09 PM, Amir Vadai <amirv@mellanox.com> wrote:
> DCBX version 802.1qaz is supported.
> User Priority (UP) is set in QP context instead of in WQE (QP Work Queue
> Element), which means that all traffic from a queue will have the same UP.
> UP is also set for untagged traffic to be able to classify such traffic too.
>
> Mapping from sk_prio to User Priority is done by sch_mqprio mapping. Although
> confusingly sch_mqprio maps sk_prio to something called TC, it is not related
> to DCBX's TC, and is interpreted by mlx4_en driver as UP.

Hi Dave,

Haven't seen a comment from you on this patch set, just wanted to
double check some points are clarified:  as was raised in the internal
review, from V0 Amir pointed out on the ratelimit patch (doesn't fit
into the current DCBNL framework) and on the queue selection patch
(changes the spirit of the HW QoS work from Jonh) that they might need
changes -  but we preferred to come up with code and not only
theoretic suggestions.

For the ratelimit Eric D. provided feedback and it was implemented
along his suggestion,
and now John and Ben have other suggestions, so need clear feedback
here not to implement this in 2-3 different ways, and this is the
easier piece. As for the HW QoS, the discussion continues.

V3 has patches 1-6 on which no objecting comment was provided, and
they should be okay for merging, unless you see things which need to
change there?

Or.
