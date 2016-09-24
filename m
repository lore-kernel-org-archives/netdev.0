From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Sat, 24 Sep 2016 13:29:14 -0700
Message-ID: <1474748954.23838.21.camel@perches.com>
References: <1474654333.1849.5.camel@perches.com>
         <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
         <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
         <1474657363.1849.9.camel@perches.com> <20160924175555.01cae6dd@endymion>
         <1474733754.23838.3.camel@perches.com>
         <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
         <1474738358.23838.11.camel@perches.com>
         <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0058.hostedemail.com ([216.40.44.58]:43490 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759519AbcIXU3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 16:29:19 -0400
In-Reply-To: <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-09-24 at 14:06 -0500, Larry Finger wrote:
> On 09/24/2016 12:32 PM, Joe Perches wrote:
[]
> o Reindent all the switch/case blocks to a more normal
>   kernel style (git diff -w would show no changes here)
> That sounds like busy work to me, but if you want to do it, go ahead.

It's really just to make the comparison case block reductions
easier to verify for later steps done

> > o cast, spacing and parenthesis reductions
> >   Lots of odd and somewhat unique styles in various
> >   drivers, looks like too many individual authors without
> >   a style guide / code enforcer using slightly different
> >   personalized code.  Glancing at the code, it looks to be
> >   similar logic, just written in different styles.
> Same comment.

Same rationale

> > o Logic changes like
> >   from:
> >     if (foo) func(..., bar, ...); else func(..., baz, ...);
> >   to:
> >     func(..., foo ? bar : baz, ...);
> >   to make the case statement code blocks more consistent
> >   and emit somewhat smaller object code.
> I find if .. else constructs much easier to read than the cond ? xxxx : yyyy 
> form. I would reject any such patches.

<shrug> I think object code reduction generally a good thing
but then again, I'm not a maintainer here.

> > o Consolidation of equivalent function spanning drivers
> >   With the style only changes minimized, where possible
> >   make the drivers use common ops/callback functions.
> The is no question that there are similar routines in different drivers. I would 
> like to place as much as possible into common routines, but I never seem to find 
> the time. There are too many bugs in other things I support to consider these 
> niceties.

Consolidation generally reduces defects and improves ease of
updating.
> 
