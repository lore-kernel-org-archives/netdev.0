From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH 2/3][v2] selftests: actually run the various net selftests
Date: Tue, 19 Sep 2017 15:31:10 -0600
Message-ID: <14cddd0b-fc00-4899-3b00-7ff6b8004808@kernel.org>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com>
 <1505829088-1823-2-git-send-email-jbacik@fb.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>, Shuah Khan <shuah@kernel.org>
To: josef@toxicpanda.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.200.34]:48873 "EHLO
        mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISVbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:31:19 -0400
In-Reply-To: <1505829088-1823-2-git-send-email-jbacik@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 07:51 AM, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> These self tests are just self contained binaries, they are not run by
> any of the scripts in the directory.  This means they need to be marked
> with TEST_GEN_PROGS to actually be run, not TEST_GEN_FILES.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
> v1->v2:
> - Moved msg_zerocopy to TEST_GEN_FILES since it's not runnable in it's current
>   state
> 

I usually don't sent new tests however, since it is a test for a
regression, applied to linux-kselftest fixes for 4.14-rc2

thanks,
-- Shuah
