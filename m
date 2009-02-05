From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: ixgbe in kernel driver question
Date: Thu, 05 Feb 2009 13:53:55 +0100
Message-ID: <498AE163.5040905@itcare.pl>
References: <49832695.7020802@itcare.pl> <Pine.WNT.4.64.0902041121030.4348@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:51036 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbZBEMx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2009 07:53:58 -0500
In-Reply-To: <Pine.WNT.4.64.0902041121030.4348@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P pisze:
>> I have question about ixgbe in kernel driver compared to ixgbe driver 
>> that is on sourceforge
>> http://sourceforge.net/project/showfiles.php?group_id=42302&package_id=247088
>>
>> What is difference between this drivers ?
>> and does driver in kernel 2.6.28.2
>>     
>
> These drivers should be relatively kept in sync.  We release our new 
> software to SourceForge first, since that is an on-demand push from Intel.  
> The upstream driver usually has the necessary patches in the queue for the 
> next kernel, but due to hardware release schedules and kernel release 
> schedules not aligning most of the time, there will be differences.
>
> Now these drivers are not intended to be identical.  One main difference, 
> for example, is the upstream driver has no module option support.  The 
> SourceForge driver does support some module options.
>
>   
>> Or this driver have different versions releases ? with different changes 
>> that are made in kernel tree network drivers
>>
>> because i have problems with in kernel ixgbe drivers that i can compare 
>> to some fixes that are made in:
>> 1.3.31.5 driver on e1000 site
>> http://sourceforge.net/project/shownotes.php?release_id=611160&group_id=42302
>>
>> i think about this fix:
>>
>> cpu utilization fix for MSI and legacy interrupts in kernels with CONFIG_NETDEVICES_MULTIQUEUE enabled but default (non multiqueue) aware qdisc loaded
>>     
>
> Yes.  These fixes are already queued or accepted for the next version of 
> the kernel driver.  The bottom line is we, Intel, own the SourceForge 
> driver and its release schedules.  The Linux community ultimately owns the 
> in-kernel driver and those release schedules, so there will almost always 
> be differences.
>
> I hope this helps,
>
> -PJ Waskiewicz
> peter.p.waskiewicz.jr@intel.com
>
>
>   
thanks for reply all is clear now.

