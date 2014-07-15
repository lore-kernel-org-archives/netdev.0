From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] udp: UDP tunnel enhancements
Date: Mon, 14 Jul 2014 18:51:04 -0700 (PDT)
Message-ID: <20140714.185104.1874161482548432012.davem@davemloft.net>
References: <alpine.DEB.2.02.1407131942580.25072@tomh.mtv.corp.google.com>
	<20140714.161254.1495587038499399882.davem@davemloft.net>
	<CA+mtBx_sBxbY7r6_mDDo0pE5Nakg3CwL71bawBMtW0fzfU1Uww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaGOBvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 21:51:07 -0400
In-Reply-To: <CA+mtBx_sBxbY7r6_mDDo0pE5Nakg3CwL71bawBMtW0fzfU1Uww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 14 Jul 2014 16:23:43 -0700

> On Mon, Jul 14, 2014 at 4:12 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Sun, 13 Jul 2014 19:49:29 -0700 (PDT)
>>
>>> - Add udp_sock_create in new helper module udp_tunnel. Tunnel
>>>   implementations call this function to create listener UDP ports.
>>> - Make vxlan and l2tp call udp_sock_create.
>>> - Move udp_tunnel_segment into udp_offload.c.
>>
>> Series applied, thank Tom.
>>
>> Please make the target tree (net-next in this case) explicit in
>> future submissions.
>>
> Thanks. Should all patch submissions to netdev either be targeted to
> net or net-next then?

Absolutely.

If you need to put a bug fix in first to 'net' then build on top of it
in 'net-next' you just need to submit the changes in that order and
let me know explicitly about the dependency.
