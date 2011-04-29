From: WeipingPan <panweiping3@gmail.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Fri, 29 Apr 2011 11:17:48 +0800
Message-ID: <4DBA2DDC.80502@gmail.com>
References: <4DB9185E.4050103@gmail.com> <20110428122102.GB4165@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39530 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758158Ab1D2DRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 23:17:34 -0400
Received: by vws1 with SMTP id 1so2459805vws.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 20:17:33 -0700 (PDT)
In-Reply-To: <20110428122102.GB4165@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2011 08:21 PM, Neil Horman wrote:
> On Thu, Apr 28, 2011 at 03:33:50PM +0800, WeipingPan wrote:
>> Hi, all,
>>
>> 802.3ad mode in bonding implements 802.3ad standard.
>>
>> I am just wondering  802.3ad mode is useful,
>> since  bonding has many modes like balance-rr, active-backup, etc.
>>
> Yes, of course its usefull.  For switches which support 802.3ad, this mode
> allows for both peers to understand that the links in the bond are acting as an
> aggregate, which makes it easier to prevent things like inadvertently looped
> back frames, for which the other modes have to have all sorts of hacks to
> prevent.
What is looped back frames here ?
I didn't see any special code to handle looped back frames in other 
modes in bonding,
can you take an example ?

thanks
Weiping Pan

> Neil
>

