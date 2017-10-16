From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 3/3][v2] selftests: silence test output by default
Date: Mon, 16 Oct 2017 14:57:02 +1100
Message-ID: <87vajflp81.fsf@concordia.ellerman.id.au>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com> <1505829088-1823-3-git-send-email-jbacik@fb.com> <89b70a11-27d9-9b56-2010-66258618cdb4@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Josef Bacik <jbacik@fb.com>, Shuah Khan <shuah@kernel.org>
To: Shuah Khan <shuah@kernel.org>, josef@toxicpanda.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:50155 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751506AbdJPD5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 23:57:04 -0400
In-Reply-To: <89b70a11-27d9-9b56-2010-66258618cdb4@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shuah Khan <shuah@kernel.org> writes:

> On 09/19/2017 07:51 AM, josef@toxicpanda.com wrote:
>> From: Josef Bacik <jbacik@fb.com>
>> 
>> Some of the networking tests are very noisy and make it impossible to
>> see if we actually passed the tests as they run.  Default to suppressing
>> the output from any tests run in order to make it easier to track what
>> failed.
>> 
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>> ---
>> v1->v2:
>> - dump output into /tmp/testname instead of /dev/null
>> 
>
> Thanks for the fix. Applied to linux-kselftest for 4.14-rc2

Sorry this is not a fix.

This is a regression, it breaks all my test infrastructure, because we
use the output of the test case.

Can we please revert this and fix any tests that are overly verbose.

cheers
