From: Joe Perches <joe@perches.com>
Subject: Re: RFC : [PATCH] IPV6: checkpatch whitespace corrections
Date: Wed, 13 Aug 2014 15:46:51 -0700
Message-ID: <1407970011.2683.9.camel@joe-AO725>
References: <1407960167-9437-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0073.hostedemail.com ([216.40.44.73]:42447 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752652AbaHMWqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 18:46:54 -0400
In-Reply-To: <1407960167-9437-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-13 at 21:02 +0100, Ian Morris wrote:
> I started looking at the ipv6 code to educate myself but in the process
> noticed a fair few trivial checkpatch issues. There are some more interesting
> ones also present but before tackling those I decided to try to reduce the 
> volume of output from checkpatch by fixing whitespace issues. Question is 
> are such patches wanted?

Like most things, it depends.

To make reviewing these patches easier, it's better to
separate these changes into at least 2 patches.

1: Horizontal line whitespace changes where git diff -w can be
   shown to have no differences
2: Vertical line whitespace changes where newlines are only
   added or deleted.

In both cases, scripts/objdiff should be run to show no compiler
object output changes occur as well.

In a quick scan, I don't see anything objectionable here.

I'm not a big fan of the forced blank line between declarations
and code though.

You can get checkpatch to not emit those with --ignore=line_spacing
