From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 06:18:35 -0800
Message-ID: <1352902715.4497.3.camel@edumazet-glaptop>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64832 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422898Ab2KNOSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:18:39 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so621789iea.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 06:18:38 -0800 (PST)
In-Reply-To: <1352897464-832-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-14 at 13:51 +0100, Jiri Pirko wrote:
> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
> sets this. Correct the check to behave properly on addr removal.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Please add in the changelog which commit added the bug, to ease
stable teams work.

Thanks
