From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 1/1] net sched: fix encoding to use real length
Date: Mon, 22 Aug 2016 21:02:11 -0700 (PDT)
Message-ID: <20160822.210211.926745178893055522.davem@davemloft.net>
References: <1471864220-13356-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbcHWECS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 00:02:18 -0400
In-Reply-To: <1471864220-13356-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 22 Aug 2016 07:10:20 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Encoding of the metadata was using the padded length as opposed to
> the real length of the data which is a bug per specification.
> This has not been an issue todate because all metadatum specified
> so far has been 32 bit where aligned and data length are the same width.
> This also includes a bug fix for validating the length of a u16 field.
> But since there is no metadata of size u16 yes we are fine to include it
> here.
> 
> While at it get rid of magic numbers.
> 
> Fixes: ef6980b6becb ("net sched: introduce IFE action")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
