From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: very simple example test cases
Date: Tue, 31 Oct 2017 14:39:39 -0400
Message-ID: <CAMDBHYKx=BSQtYF_O4d27_b5X-TT5CBMtgASdFEqMNwS9kzp5g@mail.gmail.com>
References: <20171031182546.9614-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Chris Mi <chrism@mellanox.com>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Brenda J. Butler" <bjb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:51909 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdJaSkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:40:01 -0400
Received: by mail-wm0-f52.google.com with SMTP id b9so771330wmh.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:40:00 -0700 (PDT)
In-Reply-To: <20171031182546.9614-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:25 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
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
>
>     $ sudo -E ./tdc.py -f creating-testcases/example.json -l
>     1f: (example) simple test to test framework
>     2f: (example) simple test, no need for verify
>     3f: (example) simple test, no need for setup or teardown (or verify)
>     $ sudo -E ./tdc.py -f creating-testcases/example.json
>     Test 1f: simple test to test framework
>     Test 2f: simple test, no need for verify
>     Test 3f: simple test, no need for setup or teardown (or verify)
>     All test results:
>
>     1..3
>     ok 1 1f simple test to test framework
>     ok 2 2f simple test, no need for verify
>     ok 3 3f simple test, no need for setup or teardown (or verify)
>
>     $
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
