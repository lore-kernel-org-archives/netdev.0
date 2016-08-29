From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/2] tc: Add support for the matchall traffic
 classifier.
Date: Mon, 29 Aug 2016 20:40:45 +0200
Message-ID: <20160829184045.GA2012@nanopsycho.orion>
References: <1471866986-3156-1-git-send-email-jiri@resnulli.us>
 <1471866986-3156-2-git-send-email-jiri@resnulli.us>
 <20160829110321.78959dc8@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, eladr@mellanox.com,
        idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36487 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755233AbcH2Sks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 14:40:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so10648485wmf.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 11:40:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160829110321.78959dc8@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 29, 2016 at 08:03:21PM CEST, stephen@networkplumber.org wrote:
>On Mon, 22 Aug 2016 13:56:25 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Yotam Gigi <yotamg@mellanox.com>
>> 
>> The matchall classifier matches every packet and allows the user to apply
>> actions on it. In addition, it supports the skip_sw and skip_hw (as can
>> be found on u32 and flower filter) that direct the kernel to skip the
>> software/hardware processing of the actions.
>> 
>> This filter is very useful in usecases where every packet should be
>> matched. For example, packet mirroring (SPAN) can be setup very easily
>> using that filter.
>> 
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>I am not a checkpatch purist, but these two should be addressed.
>
>
>WARNING: unnecessary whitespace before a quoted newline
>#81: FILE: tc/f_matchall.c:29:
>+	fprintf(stderr, "Usage: ... matchall [skip_sw | skip_hw] \n");
>
>WARNING: braces {} are not necessary for single statement blocks
>#185: FILE: tc/f_matchall.c:133:
>+	if (tb[TCA_MATCHALL_ACT]) {
>+		tc_print_action(f, tb[TCA_MATCHALL_ACT]);
>+	}

will fix and send v2. Thanks.
