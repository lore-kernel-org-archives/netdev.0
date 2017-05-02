From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC 1/1] net netlink: Add new type
 NLA_FLAG_BITS
Date: Tue, 02 May 2017 15:03:45 -0400 (EDT)
Message-ID: <20170502.150345.954488149548327006.davem@davemloft.net>
References: <1493562519-15563-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52726 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdEBTDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:03:47 -0400
In-Reply-To: <1493562519-15563-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 30 Apr 2017 10:28:39 -0400

> Generic bitflags attribute content sent to the kernel by user.
> With this type the user can either set or unset a flag in the
> kernel.

You asked for feedback, here it is :-)

I think this is overengineered.

Just define a u32 for the value, and mask which defines which bits are
legitimate and defined.  Any bit outside of the legitimate mask must
be zero.

Simple.
