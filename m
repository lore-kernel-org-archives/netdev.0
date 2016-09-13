From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH v2 6/6] selftests: move watchdog tests from
 Documentation/watchdog
Date: Tue, 13 Sep 2016 14:48:55 -0600
Message-ID: <3eb32f56-eac7-e0ca-0bcf-90488cbff458@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
 <328de4c08ef23fe13cec88b45e3e1725cfc5c33b.1473795601.git.shuahkh@osg.samsung.com>
 <57D8628D.3070507@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kselftest-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, corbet-T1hC0tSOHrs@public.gmane.org,
        richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org,
        nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org, maheshkhanwalkar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        ghackmann-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, thuth-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        christopher.s.hall-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org,
        jani.nikula-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57D8628D.3070507-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/13/2016 02:33 PM, Timur Tabi wrote:
> Shuah Khan wrote:
>> Remove watchdog-test from Makefile to move the test to selftests.
>>
>> Add Makefile and .gitignore to for watchdog-test. watchdog-test will
> 
> to for?

Thanks - will fix that.

> 
>> not be run as part of selftests suite and will not be included in
>> install targets.  It can be built separately for now.
>>
>> Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
>> ---
>>   Documentation/watchdog/src/.gitignore            |   1 -
>>   Documentation/watchdog/src/Makefile              |   2 +-
>>   Documentation/watchdog/src/watchdog-test.c       | 105 -----------------------
>>   tools/testing/selftests/watchdog/.gitignore      |   1 +
>>   tools/testing/selftests/watchdog/Makefile        |   8 ++
>>   tools/testing/selftests/watchdog/watchdog-test.c | 105 +++++++++++++++++++++++
> 
> Please use -M when calling git-format-patch

okay.

> 
>>   6 files changed, 115 insertions(+), 107 deletions(-)
>>   delete mode 100644 Documentation/watchdog/src/watchdog-test.c
>>   create mode 100644 tools/testing/selftests/watchdog/.gitignore
>>   create mode 100644 tools/testing/selftests/watchdog/Makefile
>>   create mode 100644 tools/testing/selftests/watchdog/watchdog-test.c
>>
>> diff --git a/Documentation/watchdog/src/.gitignore b/Documentation/watchdog/src/.gitignore
>> index ac90997..ff0ebb5 100644
>> --- a/Documentation/watchdog/src/.gitignore
>> +++ b/Documentation/watchdog/src/.gitignore
>> @@ -1,2 +1 @@
>>   watchdog-simple
>> -watchdog-test
> 
> Why not also watchdog-simple?
> 

Is watchdog-simple a test or a sample/example? I thought this
is an example, and planning to move that under examples?

If this is a test, I will re-do the patch to include it.

thanks,
-- Shuah

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
