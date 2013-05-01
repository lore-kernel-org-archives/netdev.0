From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH v2] iproute2: act_ipt fix xtables breakage on
 older versions.
Date: Wed, 01 May 2013 10:22:06 -0400
Message-ID: <5181250E.70303@mojatatu.com>
References: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f172.google.com ([209.85.210.172]:43736 "EHLO
	mail-ia0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3EAOWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 10:22:08 -0400
Received: by mail-ia0-f172.google.com with SMTP id i20so1382190ian.17
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 07:22:08 -0700 (PDT)
In-Reply-To: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-29 11:50 AM, Alexander Duyck wrote:
> In trying to build on a RHEL6.3 I ran into several build issues that are
> addressed in this patch.
>
> The first is that xtables_merge_options only has 3 parameters.  It appears
> this is how this code was originally.  As such for the case where the version
> is less than 6 I am assuming it would be correct to maintain the original
> setup that only had 3 parameters being passed instead of 4.
>
> I also ran into an issue with the define for __ALIGN_KERNEL not being present.
> I believe this may be due to the fact that __ALIGN_KERNEL was moved into a
> separate header from ALIGN after the UAPI changes.  In order to just cover all
> of the bases I have moved the main definition for the macros into
> __ALIGN_KERNEL_MASK and __ALIGN_KERNEL and if ALIGN is also needed then it is
> just a direct redefine to __ALIGN_KERNEL.
>
> Cc: Hasan Chowdhury <shemonc@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>



Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
