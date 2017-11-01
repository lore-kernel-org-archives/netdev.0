From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc-testing: very simple example test cases
Date: Wed, 01 Nov 2017 11:05:31 +0900 (KST)
Message-ID: <20171101.110531.994137137362345579.davem@davemloft.net>
References: <20171031182546.9614-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:05:36 -0400
In-Reply-To: <20171031182546.9614-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Tue, 31 Oct 2017 14:25:46 -0400

> As part of documentation, supply some very simple test cases
> to illustrate how test cases work.  One test case shows
> commands in the setup, command, verify and teardown stages.
> Other test cases show how to have a working test case that
> does not have commands in the setup, verify and/or teardown
> stages.
> 
> Specifically, the command lists for setup and teardown can
> be empty.  And the verify command must have a command, but
> it can be /bin/true.  The regex must have a string, we
> recommend a single space, and the count of matches must be
> zero if you do not want to use the match feature of verify.
> Verify will always look for a return code of success (0)
> so we give /bin/true when we do not want to make a check
> there.
> 
> Also, update the documentation for testcases to be more
> specific in the cases of:
> 
>     - accepting non-success return codes in setup and
>       teardown stages
>     - how to write the test when no setup, teardown
>       and/or verify are desired.
> 
> To run the example test cases:
 ...
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Applied.
