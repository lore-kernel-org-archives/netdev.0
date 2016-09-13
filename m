From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 2/9] selftests: update filesystems Makefile to work under
 selftests
Date: Tue, 13 Sep 2016 07:20:56 -0600
Message-ID: <4756400f-e332-a652-f759-6655acdb39cd@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
 <239195aa67e72b7eb971cdacfc9e338de912524e.1473458697.git.shuahkh@osg.samsung.com>
 <87fup4ovx6.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-kselftest@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Michael Ellerman <mpe@ellerman.id.au>, corbet@lwn.net,
        richardcochran@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <87fup4ovx6.fsf@concordia.ellerman.id.au>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/13/2016 05:56 AM, Michael Ellerman wrote:
> Shuah Khan <shuahkh@osg.samsung.com> writes:
> 
>> Update to work under selftests. dnotify_test will not be run as part of
>> selftests suite and will not included in install targets. It can be built
>> separately for now.
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
>> ---
>>  tools/testing/selftests/filesystems/Makefile | 10 ++++++----
>>  1 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
>> index 883010c..f1dce5c 100644
>> --- a/tools/testing/selftests/filesystems/Makefile
>> +++ b/tools/testing/selftests/filesystems/Makefile
>> @@ -1,5 +1,7 @@
>> -# List of programs to build
>> -hostprogs-y := dnotify_test
>> +TEST_PROGS := dnotify_test
>> +all: $(TEST_PROGS)
>>  
>> -# Tell kbuild to always build the programs
>> -always := $(hostprogs-y)
>> +include ../lib.mk
>> +
>> +clean:
>> +	rm -fr dnotify_test
> 
> That's a complete rewrite of the Makefile, so I don't think there's any
> value in bringing its content across from Documentation.

Moving Makefile accomplishes delete at the same time. I can combine
the move and updating Makefile into one single patch.

> 
> Better IMHO would be to squash this with the previous patch, so we get a
> working test under selftests in a single commit.
> 
> cheers
> 

thanks,
-- Shuah
