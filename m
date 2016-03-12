From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 0/3] bridge: ageing timer regression fix
Date: Sat, 12 Mar 2016 10:46:30 +0100
Message-ID: <20160312094630.GA2127@nanopsycho.orion>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
 <20160311.150448.895454572947313792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35385 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbcCLJqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 04:46:33 -0500
Received: by mail-wm0-f67.google.com with SMTP id n205so6388734wmf.2
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 01:46:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160311.150448.895454572947313792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 11, 2016 at 09:04:48PM CET, davem@davemloft.net wrote:
>From: Stephen Hemminger <stephen@networkplumber.org>
>Date: Tue,  8 Mar 2016 12:59:32 -0800
>
>> This fixes regression in how ageing timer is managed.
>> Backing out the change required fixing switch drivers as well.
>
>Series applied, thanks.
>
>Jiri, since I applied this to net-next, I had to deal with the conflicts
>created by your world splitup of the rocker driver.  I wasn't sure, while
>doing so, whether you'd like this new ageing_time member to remain in the
>rocker struct, as in Stephen's patch, or to be placed in the ofdpa struct.
>I choose the former, send me a patch if you want the latter.

Yeah, it belongs into ofdpa. I'll send you patch in a jiff. Thanks!
