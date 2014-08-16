From: Ian Morris <ipm@chirality.org.uk>
Subject: Re: RFC : [PATCH] IPV6: checkpatch whitespace corrections
Date: Sat, 16 Aug 2014 09:48:16 +0100
Message-ID: <53EF1AD0.7080704@chirality.org.uk>
References: <1407960167-9437-1-git-send-email-ipm@chirality.org.uk> <1407970011.2683.9.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:42745 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751058AbaHPIsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 04:48:21 -0400
In-Reply-To: <1407970011.2683.9.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many thanks for taking the time to provide feedback. Accordingly I will 
break the patch into better structured parts and submit.

On 13/08/14 23:46, Joe Perches wrote:
> On Wed, 2014-08-13 at 21:02 +0100, Ian Morris wrote:
>> I started looking at the ipv6 code to educate myself but in the process
>> noticed a fair few trivial checkpatch issues. There are some more interesting
>> ones also present but before tackling those I decided to try to reduce the
>> volume of output from checkpatch by fixing whitespace issues. Question is
>> are such patches wanted?
> Like most things, it depends.
>
> To make reviewing these patches easier, it's better to
> separate these changes into at least 2 patches.
>
> 1: Horizontal line whitespace changes where git diff -w can be
>     shown to have no differences
> 2: Vertical line whitespace changes where newlines are only
>     added or deleted.
>
> In both cases, scripts/objdiff should be run to show no compiler
> object output changes occur as well.
>
> In a quick scan, I don't see anything objectionable here.
>
> I'm not a big fan of the forced blank line between declarations
> and code though.
>
> You can get checkpatch to not emit those with --ignore=line_spacing
>
>
>
