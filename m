From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue, 09 Apr 2013 15:54:04 +0200
Message-ID: <51641D7C.3010006@redhat.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com> <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com> <51641A09.7040108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandru Copot <alex.mihai.c@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, willemb@google.com, edumazet@google.com,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762069Ab3DINyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:54:13 -0400
In-Reply-To: <51641A09.7040108@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 03:39 PM, Sergei Shtylyov wrote:
> On 09-04-2013 14:30, Alexandru Copot wrote:
>> Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
>> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> [...]
>
>> diff --git a/tools/testing/selftests/net/selftests.c b/tools/testing/selftests/net/selftests.c
>> new file mode 100644
>> index 0000000..cd6e427
>> --- /dev/null
>> +++ b/tools/testing/selftests/net/selftests.c
>> @@ -0,0 +1,30 @@
[...]
>> +    for (i = 0; i < test->testcase_count; i++) {
>> +        rc = test->run(ptr);
>> +        allrc |= rc;
>> +
>> +        if (test->abort_on_fail && rc) {
>> +            printf("Testcase %d failed, aborting\n", i);
>> +        }
>
>     Nit: {} not needed here, at least if you folow the Linux coding style (you seem to).

We already figured out earlier in this thread that a ``break'' was missing. ;-)
