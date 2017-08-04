From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/20] net: sched: summer cleanup part 1,
 mainly in exts area
Date: Fri, 04 Aug 2017 11:23:21 -0700 (PDT)
Message-ID: <20170804.112321.1160679995362189447.davem@davemloft.net>
References: <20170804122915.15177-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdHDSXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 14:23:22 -0400
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  4 Aug 2017 14:28:55 +0200

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
> Patches 9-10 do simple renames of functions in cls*
> Patches 11-19 remove unnecessary calls of tcf_exts_change helper
> The last patch changes tcf_exts_change to don't take lock
> 
> Tested by tools/testing/selftests/tc-testing
> 
> v1->v2:
> - removed conversion of action array to list as noted by Cong
> - added the past patch instead
> - small rebases of patches 11-19

Series applied, thanks Jiri.
