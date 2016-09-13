From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: Re: [PATCH 0/9] Move runnable code (tests) from Documentation to selftests
Date: Tue, 13 Sep 2016 16:45:44 +0300
Message-ID: <87eg4n29rr.fsf@intel.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com> <20160910010100.72f1a9c4@lwn.net> <87sht4tav2.fsf@intel.com> <235dbbac-4950-9631-908a-b2dfbbd06def@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: richardcochran@gmail.com, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Shuah Khan <shuahkh@osg.samsung.com>,
        Markus Heiser <markus.heiser@darmarit.de>
To: Shuah Khan <shuahkh@osg.samsung.com>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <235dbbac-4950-9631-908a-b2dfbbd06def@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Sep 2016, Shuah Khan <shuahkh@osg.samsung.com> wrote:
> On 09/13/2016 03:20 AM, Jani Nikula wrote:
>> FWIW, I'm in favor of moving *all* the code away from Documentation, not
>> just tests. Essentially removing the CONFIG_BUILD_DOCSRC config option,
>> and reserving Documentation/Makefile for documentation build. After this
>> series, some of the remaining code belongs under samples, some under
>> tools.
>
> I am planning another patch series to move all the examples and samples
> and tools to their right location.

Great!

>> We could make it possible to include the code samples from samples into
>> the Sphinx built documentation.
>
> I can't say I understand Sphinx, however, it might make sense to include
> samples into Sphinx build. Is this approach different from the way they
> are built under Documentation via Doc Makfiles now?

It's just that by default Sphinx won't allow including files outside of
its root directory, which is Documentation in this case. It just needs
an extension for this.

BR,
Jani.


-- 
Jani Nikula, Intel Open Source Technology Center
