From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: power on MII block for all MII modes
Date: Mon, 29 Jun 2015 17:06:52 -0700
Message-ID: <5591DD9C.8050009@gmail.com>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>	<1435340314-10229-2-git-send-email-f.fainelli@gmail.com> <20150628.202739.1152355107671800451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33340 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbbF3AI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 20:08:28 -0400
Received: by pdjd13 with SMTP id d13so87234pdj.0
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 17:08:28 -0700 (PDT)
In-Reply-To: <20150628.202739.1152355107671800451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/06/15 20:27, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Fri, 26 Jun 2015 10:38:31 -0700
> 
>> The RGMII block is currently only powered on when using RGMII or
>> RGMII_NO_ID, which is not correct when using the GENET interface in MII
>> or Reverse MII modes. We always need to power on the RGMII interface for
>> this block to properly work, regardless of the MII mode in which we
>> operate.
>>
>> Fixes: aa09677cba423 ("net: bcmgenet: add MDIO routines")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> David,
>>
>> I am targetting "net" here since this is a bug fix, however, we have few
>> people using MII or Reverse MII with GENET, such that there is no need to
>> queue this for -stable unless you want to.
> 
> This does not apply cleanly to the net tree, please respin.

You can discard this patch, it was applied earlier and was mistakenly
sent again. Thanks!
-- 
Florian
