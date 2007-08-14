From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] remove Documentation/networking/net-modules.txt
Date: Wed, 15 Aug 2007 00:22:45 +0200
Message-ID: <20070814222245.GF18945@stusta.de>
References: <20070814212604.GW18945@stusta.de> <46C226D1.4070203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:47460 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S936767AbXHNWW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 18:22:56 -0400
Content-Disposition: inline
In-Reply-To: <46C226D1.4070203@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 06:04:01PM -0400, Jeff Garzik wrote:
> Adrian Bunk wrote:
>> According to git, the only one who touched this file during the last
>> 5 years was me when removing drivers...
>> modinfo offers less ancient information.
>> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>> ---
>> This patch has been sent on:
>> - 23 Jul 2007
>>  Documentation/networking/00-INDEX        |    2  
>> Documentation/networking/net-modules.txt |  315 -----------------------
>>  2 files changed, 317 deletions(-)
>
> NAK, IMO it's still use for ancient drivers

Is there any that lacks a MODULE_PARM_DESC()?
If yes, shouln't we fix such drivers instead?

Even for ancient drivers net-modules.txt is outdated and sometimes lists 
no longer existing or doesn't document more recent parameters.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

