From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 2/2] tc: add support for BPF based actions
Date: Wed, 14 Jan 2015 10:19:19 +0100
Message-ID: <20150114091919.GB1869@nanopsycho.orion>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
 <1420649244-9574-1-git-send-email-jiri@resnulli.us>
 <1420649244-9574-2-git-send-email-jiri@resnulli.us>
 <20150113171917.4d4cdafb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:57809 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbANJTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 04:19:22 -0500
Received: by mail-we0-f176.google.com with SMTP id w61so7548306wes.7
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 01:19:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113171917.4d4cdafb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 14, 2015 at 02:19:17AM CET, stephen@networkplumber.org wrote:
>On Wed,  7 Jan 2015 17:47:24 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/tc_act/tc_bpf.h |  31 +++++++
>
>The overall concept is fine, but the mechanics of file management
>gets in the way.
>
>All header files in the linux directory of iproute2 must come from sanitized
>version of kernel headers that are in uapi/linux in the kernel source.
>
>I take headers from 'make install_headers' and copy them over to keep
>in sync. The headers for master branch are kept in sync with upstream
>kernel (from Linus tree), and for net-next branch I derive them from Davem's
>net-next tree.
>
>If you want to use tc_bpf.h it has to be in upstream kernel first.

Sure. I will reposet these patches once act_bpf code is applied to
net-next kernel tree. Thanks!
