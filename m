From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH 3/3][v2] selftests: silence test output by default
Date: Tue, 19 Sep 2017 15:31:59 -0600
Message-ID: <89b70a11-27d9-9b56-2010-66258618cdb4@kernel.org>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com>
 <1505829088-1823-3-git-send-email-jbacik@fb.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>, Shuah Khan <shuah@kernel.org>
To: josef@toxicpanda.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.200.34]:60084 "EHLO
        mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdISVcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:32:08 -0400
In-Reply-To: <1505829088-1823-3-git-send-email-jbacik@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 07:51 AM, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Some of the networking tests are very noisy and make it impossible to
> see if we actually passed the tests as they run.  Default to suppressing
> the output from any tests run in order to make it easier to track what
> failed.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
> v1->v2:
> - dump output into /tmp/testname instead of /dev/null
> 

Thanks for the fix. Applied to linux-kselftest for 4.14-rc2

-- Shuah
