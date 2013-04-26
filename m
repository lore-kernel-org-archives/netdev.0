From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Fri, 26 Apr 2013 09:20:41 -0400
Message-ID: <517A7F29.7070903@mojatatu.com>
References: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45786 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab3DZNUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 09:20:44 -0400
Received: by mail-ie0-f175.google.com with SMTP id a11so4920593iee.34
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 06:20:44 -0700 (PDT)
In-Reply-To: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-25 06:07 PM, Alexander Duyck wrote:
> In trying to build on a RHEL6.3 I ran into several build issues that are
> addressed in this patch.
>
> The first is that xtables_options_xfrm only has 3 options.  It appears this is
> how this code was originally.  As such for the case where the version is less
> than 6 I am assuming it would be correct to maintain the original setup that
> only had 3 parameters being passed instead of 4.
>


Getting it to compile is insufficient get it to work.
We've gone over the specific issues you are running into and infact 
patches exist for both iproute2 and the kernel. I'll see if i can get 
something out this weekend.
Hasan, you never got back to me on our last email exchange whether the
proposed changes worked out. Can you please provide me some feedback?

cheers,
jamal
