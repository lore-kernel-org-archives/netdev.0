From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 0/9] Move runnable code (tests) from Documentation to
 selftests
Date: Tue, 13 Sep 2016 07:25:50 -0600
Message-ID: <235dbbac-4950-9631-908a-b2dfbbd06def@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
 <20160910010100.72f1a9c4@lwn.net> <87sht4tav2.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Jani Nikula <jani.nikula@linux.intel.com>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35616
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757906AbcIMNZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 09:25:55 -0400
In-Reply-To: <87sht4tav2.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2016 03:20 AM, Jani Nikula wrote:
> On Sat, 10 Sep 2016, Jonathan Corbet <corbet@lwn.net> wrote:
>> On Fri,  9 Sep 2016 16:22:41 -0600
>> Shuah Khan <shuahkh@osg.samsung.com> wrote:
>>
>>> Move runnable code (tests) from Documentation to selftests and update
>>> Makefiles to work under selftests.
>>>
>>> Jon Corbet and I discussed this in an email thread and as per that
>>> discussion, this patch series moves all the tests that are under the
>>> Documentation directory to selftests. There is more runnable code in
>>> the form of examples and utils and that is going to be another patch
>>> series. I moved just the tests and left the documentation files as is.
>>
>> I'm fine with the idea, but it looks like a couple of tweaks are needed,
>> in particular to avoid leaving behind dangling references in
>> Documentation/Makefile that cause build errors.
>>
>> I think the individual patches probably need a wider CC list as well.
>> I'd use the get_maintainer script (or git) to see who has taken an
>> interest in the individual tests and make sure they are aware of the
>> move.
> 
> FWIW, I'm in favor of moving *all* the code away from Documentation, not
> just tests. Essentially removing the CONFIG_BUILD_DOCSRC config option,
> and reserving Documentation/Makefile for documentation build. After this
> series, some of the remaining code belongs under samples, some under
> tools.

I am planning another patch series to move all the examples and samples
and tools to their right location.

> 
> We could make it possible to include the code samples from samples into
> the Sphinx built documentation.
> 
> BR,
> Jani.
> 

I can't say I understand Sphinx, however, it might make sense to include
samples into Sphinx build. Is this approach different from the way they
are built under Documentation via Doc Makfiles now?

thanks,
-- Shuah
