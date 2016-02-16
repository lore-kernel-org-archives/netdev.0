From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 22:46:19 +0200
Message-ID: <CAJ3xEMizet2Cz53dd1LxseO6F=CSO1doFuThJYCQquR7n=cBuQ@mail.gmail.com>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
	<CAJ3xEMhqHbHDH06O5+Y_2mNQM3BNVA9bCLBS70ZK+=-6upDtaA@mail.gmail.com>
	<20160216.145055.1581160555302651949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: john fastabend <john.fastabend@gmail.com>,
	Amir Vadai <amir@vadai.me>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36290 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbcBPUqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:46:20 -0500
Received: by mail-ig0-f174.google.com with SMTP id xg9so83004969igb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:46:20 -0800 (PST)
In-Reply-To: <20160216.145055.1581160555302651949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 9:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Tue, 16 Feb 2016 21:30:18 +0200

>> I thought we've got into agreement in netdev that the offloading
>> directive would be a tri-state creature (sw, hw and fail the op if
>> can't, hw and fallback to sw). Can you please elaborate what do you
>> mean by "make the offload decision per rule using flags similar to how
>> we do l2 mac updates"

> I think John's changes are an intermediate step in a long term evolution.

sure

> I'm going to apply John's changes as-is, and people can submit relative
> changes on top if they want.

Understood, still I'd be happy to hear what does make the offload
decision per rule using flags similar to how we do l2 mac updates
means. Re the tri-state which you've referred to in netdev -- my
understanding is that we're talking on that flag coming from the user
as part of the tc command line.

Or.
