From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Fri, 23 Sep 2016 12:02:43 -0700
Message-ID: <1474657363.1849.9.camel@perches.com>
References: <1474654333.1849.5.camel@perches.com>
         <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
         <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0167.hostedemail.com ([216.40.44.167]:55857 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1035257AbcIWTCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 15:02:47 -0400
In-Reply-To: <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-23 at 13:59 -0500, Larry Finger wrote:
> I'm not familiar with the %#x format. What does it do?

Outputs SPECIAL prefix, it's the same as "0x%x"

lib/vsprintf.c:
#define SPECIAL	64		/* prefix hex with "0x", octal with "0" */
