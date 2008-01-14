From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH 2/2] ixgb: enable sun hardware support for broadcom phy
Date: Mon, 14 Jan 2008 11:43:51 -0800
Message-ID: <478BBB77.40404@sun.com>
References: <20071214194829.15478.2510.stgit@localhost.localdomain>
 <20071214194836.15478.85555.stgit@localhost.localdomain>
 <47671FBD.4010402@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=UTF-8
Content-Transfer-Encoding: 7BIT
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:49796 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbYANTxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:53:49 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m0EJhw9A029743
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 11:43:59 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JUN00801F2FGQ00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Mon,
 14 Jan 2008 11:43:58 -0800 (PST)
In-reply-to: <47671FBD.4010402@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Matheos Worku <matheos.worku@sun.com>
>>
>> Implement support for a SUN-specific PHY.
>>
>> SUN provides a modified 82597-based board with their own
>> PHY that works with very little modification to the code. This
>> patch implements this new PHY which is identified by the
>> subvendor device ID. The device ID of the adapter remains
>> the same.
>>
>> Signed-off-by: Matheos Worku <matheos.worku@sun.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/ixgb/ixgb_hw.c   |   82 
>> +++++++++++++++++++++++++++++++++++++++++-
>>  drivers/net/ixgb/ixgb_hw.h   |    3 +-
>>  drivers/net/ixgb/ixgb_ids.h  |    4 ++
>>  drivers/net/ixgb/ixgb_main.c |   10 +++--
>>  4 files changed, 91 insertions(+), 8 deletions(-)
> 
> applied #upstream
> 
> 

Jeff,
Bleated Happy New Year.

I was wondering when this patch will  make  it to Linus' and other 
trees. I just checked Linus's and other net trees, including 
git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git and I see only 
the other patch's commit: 3fd7131feacc01c1e23e46c416228f36ebdcc0d4, and 
not this patch.


Regards
Matheos
