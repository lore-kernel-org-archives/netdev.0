From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH linux 0/2] net sched actions: access to
 uninitialized data and error handling
Date: Mon, 17 Apr 2017 10:59:47 -0400 (EDT)
Message-ID: <20170417.105947.202929252465875756.davem@davemloft.net>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jhs@mojatatu.com
To: w.bumiller@proxmox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdDQO7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 10:59:50 -0400
In-Reply-To: <20170412142140.26649-1-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Date: Wed, 12 Apr 2017 16:21:38 +0200

> Commit 1045ba77a ("net sched actions: Add support for user cookies")
> added code to net/sched/act_api.c's tcf_action_init_1 using the `tb`
> nlattr array unconditionally, while it was otherwise used as well as
> initialized only when `name == NULL`:
...
> I'm not sure why the TC_ACT_COOKIE code was added to tcf_action_init_1
> where it is now. It makes me think that it's supposed to be available
> universally, but the `name == NULL` check for how nla is used or passed
> to ->init() shows that the there are various different TC_ACT_* enums in
> use at this point, hence the 'RFC' part of the patches, I'm not that
> familiar with the code yet.

Jamal please review this.
