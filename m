From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 21:30:18 +0200
Message-ID: <CAJ3xEMhqHbHDH06O5+Y_2mNQM3BNVA9bCLBS70ZK+=-6upDtaA@mail.gmail.com>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amir@vadai.me>, Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34044 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454AbcBPTaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:30:18 -0500
Received: by mail-ig0-f174.google.com with SMTP id g6so39109357igt.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 11:30:18 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 8:00 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
[...]

> Specifically this uses a 'big hammer' feature bit
> to do the offload or not. If the bit is set you get offloaded rules
> if it is not then rules will not be offloaded. If we can agree on
> this patch series there are some more patches on my queue we can
> talk about to make the offload decision per rule using flags similar
> to how we do l2 mac updates. Additionally the error strategy can
> be improved to be hard aborting, log and continue, etc. I think
> these are nice to have improvements but shouldn't block this series.

John,

I thought we've got into agreement in netdev that the offloading
directive would be a tri-state creature (sw, hw and fail the op if
can't, hw and fallback to sw). Can you please elaborate what do you
mean by "make the offload decision per rule using flags similar to how
we do l2 mac updates"

Or.
