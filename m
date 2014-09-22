From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/2 v2] net: bcmgenet: TX reclaim and DMA fixes
Date: Mon, 22 Sep 2014 15:43:12 -0700
Message-ID: <5420A600.4030301@gmail.com>
References: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com> <20140922.183943.104495150444696692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33400 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbaIVWn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 18:43:29 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so5996501pad.21
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 15:43:29 -0700 (PDT)
In-Reply-To: <20140922.183943.104495150444696692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2014 03:39 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 22 Sep 2014 11:54:41 -0700
> 
>> This patch set contains one fix for an accounting problem while reclaiming
>> transmitted buffers having fragments, and the second fix is to make sure
>> that the DMA shutdown is properly controlled.
> 
> Series applied, but I can't see how you could have possibly
> functionally tested the original patch series if it didn't
> even compile :-/

I cherry picked the second patch from my downstream tree which had a
different function re-arrangement, and I must admit I thought I also had
compiled the second patch, while I did not...
--
Florian
