From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH v2 6/6] selftests: move watchdog tests from
 Documentation/watchdog
Date: Tue, 13 Sep 2016 15:33:17 -0500
Message-ID: <57D8628D.3070507@codeaurora.org>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
 <328de4c08ef23fe13cec88b45e3e1725cfc5c33b.1473795601.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-watchdog@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>, corbet@lwn.net,
        richardcochran@gmail.com, wim@iguana.be, linux@roeck-us.net,
        nab@linux-iscsi.org, maheshkhanwalkar@gmail.com, arnd@arndb.de,
        ghackmann@google.com, ben@decadent.org.uk, thuth@redhat.com,
        christopher.s.hall@intel.com, john.stultz@linaro.org,
        sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au,
        jani.nikula@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60204 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754636AbcIMUde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 16:33:34 -0400
In-Reply-To: <328de4c08ef23fe13cec88b45e3e1725cfc5c33b.1473795601.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shuah Khan wrote:
> Remove watchdog-test from Makefile to move the test to selftests.
>
> Add Makefile and .gitignore to for watchdog-test. watchdog-test will

to for?

> not be run as part of selftests suite and will not be included in
> install targets.  It can be built separately for now.
>
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
>   Documentation/watchdog/src/.gitignore            |   1 -
>   Documentation/watchdog/src/Makefile              |   2 +-
>   Documentation/watchdog/src/watchdog-test.c       | 105 -----------------------
>   tools/testing/selftests/watchdog/.gitignore      |   1 +
>   tools/testing/selftests/watchdog/Makefile        |   8 ++
>   tools/testing/selftests/watchdog/watchdog-test.c | 105 +++++++++++++++++++++++

Please use -M when calling git-format-patch

>   6 files changed, 115 insertions(+), 107 deletions(-)
>   delete mode 100644 Documentation/watchdog/src/watchdog-test.c
>   create mode 100644 tools/testing/selftests/watchdog/.gitignore
>   create mode 100644 tools/testing/selftests/watchdog/Makefile
>   create mode 100644 tools/testing/selftests/watchdog/watchdog-test.c
>
> diff --git a/Documentation/watchdog/src/.gitignore b/Documentation/watchdog/src/.gitignore
> index ac90997..ff0ebb5 100644
> --- a/Documentation/watchdog/src/.gitignore
> +++ b/Documentation/watchdog/src/.gitignore
> @@ -1,2 +1 @@
>   watchdog-simple
> -watchdog-test

Why not also watchdog-simple?



-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
