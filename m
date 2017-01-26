From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/5] ibmvnic: Fix MTU settings
Date: Thu, 26 Jan 2017 12:56:58 -0500 (EST)
Message-ID: <20170126.125658.909712109140919732.davem@davemloft.net>
References: <1485378143-5084-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <20170125.230504.215468934911959234.davem@davemloft.net>
        <783c7683-1cc2-6128-e19c-fd2c3c16cf4b@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com,
        jallen@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org,
        nfont@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754022AbdAZR5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:57:05 -0500
In-Reply-To: <783c7683-1cc2-6128-e19c-fd2c3c16cf4b@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu, 26 Jan 2017 10:44:31 -0600

> On 01/25/2017 10:05 PM, David Miller wrote:
>> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> Date: Wed, 25 Jan 2017 15:02:20 -0600
>>
>>> In the current driver, the MTU is set to the maximum value
>>> capable for the backing device. This patch sets the MTU to the
>>> default value for a Linux net device.
>> Why are you doing this?
>>
>> What happens to users who depend upon the current behavior.
>>
>> They will break, and that isn't acceptable.
>>
> The current behavior was already broken.  We were seeing firmware errors when sending jumbo sized packets .  We plan to add proper support for jumbo sized packets as soon as possible.  

Need to be explained, with a full detailed history of how things got this way,
in your commit message.

 
