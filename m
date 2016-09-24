From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Sat, 24 Sep 2016 17:55:55 +0200
Message-ID: <20160924175555.01cae6dd@endymion>
References: <1474654333.1849.5.camel@perches.com>
        <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
        <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
        <1474657363.1849.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36275 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754881AbcIXP4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Sep 2016 11:56:00 -0400
In-Reply-To: <1474657363.1849.9.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe, Larry,

On Fri, 23 Sep 2016 12:02:43 -0700, Joe Perches wrote:
> On Fri, 2016-09-23 at 13:59 -0500, Larry Finger wrote:
> > I'm not familiar with the %#x format. What does it do?
> 
> Outputs SPECIAL prefix, it's the same as "0x%x"
> 
> lib/vsprintf.c:
> #define SPECIAL	64		/* prefix hex with "0x", octal with "0" */

Is hexadecimal actually the best way to display these values? I guess it
depends how they are listed in the datasheets (if there's anything like
that for these chips?)

I found it a bit difficult to look up the meaning of the value.
HAL_DEF_WOWLAN is an enum value, the number is not set and there's no
comment. I had to count the line numbers, taking blank lines into
account... I ended up pasting the whole enum to a random C file and
printing the value of HAL_DEF_WOWLAN to make sure it was 92.

Would it make sense to explicitly set the enum values, or add them as
comments, to make such look-ups easier?

-- 
Jean Delvare
SUSE L3 Support
