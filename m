From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/20] net: sched: summer cleanup part 1,
 mainly in exts area
Date: Mon, 31 Jul 2017 14:35:30 -0700 (PDT)
Message-ID: <20170731.143530.1446378598611188601.davem@davemloft.net>
References: <20170728144042.6380-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdGaVfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:35:31 -0400
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 28 Jul 2017 16:40:22 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset is one of the couple cleanup patchsets I have in queue.
> The motivation aside the obvious need to "make things nicer" is also
> to prepare for shared filter blocks introduction. That requires tp->q
> removal, and therefore removal of all tp->q users.
> 
> Patch 1 is just some small thing I spotted on the way
> Patch 2 removes one user of tp->q, namely tcf_em_tree_change
> Patches 3-8 do preparations for exts->nr_actions removal
> Patch 9 does the conversion of action array into rcuized list. This is also
>         one tp->q user removal.
> Patches 10-11 do simple renames of functions in cls*
> The rest of the patches remove unnecessary calls of tcf_exts_change helper.
> 
> Tested by tools/testing/selftests/tc-testing

It looks like patch #9 needs some changes, or at least more explanation
in the commit log message, based upon Cong's feedback.
