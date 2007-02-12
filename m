From: dragoran <drago01@gmail.com>
Subject: Re: [ipw3945-devel] [ANNOUNCE] d80211 based driver for Intel	PRO/Wireless
 3945ABG
Date: Mon, 12 Feb 2007 17:32:15 +0100
Message-ID: <45D0968F.8040103@gmail.com>
References: <45CCE3CA.4050904@linux.intel.com>	<200702101424.00156.mail@earthworm.de> <200702101525.56820.mail@earthworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net
To: "Hesse, Christian" <mail@earthworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:53910 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964936AbXBLQcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 11:32:19 -0500
Received: by ug-out-1314.google.com with SMTP id 44so638259uga
        for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 08:32:17 -0800 (PST)
In-Reply-To: <200702101525.56820.mail@earthworm.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hesse, Christian wrote:
> On Saturday 10 February 2007 14:23, Hesse, Christian wrote:
>   
>> On Friday 09 February 2007 22:12, James Ketrenos wrote:
>>     
>>> We are pleased to announce the availability of a new driver for the
>>> Intel PRO/Wireless 3945ABG Network Connection adapter.
>>>       
>> Wow, great news on this rainy saturday! ;-)
>>
>> The driver works perfectly, I'm writing this mail via wireless link.
>> However there are two things to note:
>>
>> The driver generates two network devices. The second one is for promicious
>> mode? Is there any chance to disable the interface? ifrename renamed the
>> wrong one to wlan0 and I had to tell my system to use eth1 for the wireless
>> connection.
>>
>> Second problem is that I can't unload the module. I get the message "FATAL:
>> Module iwlwifi is in use." even if both interfaces are down.
>>     
>
> Oh, I forgot one note: "make patch_kernel" is terribly broken. Any chance to 
> get this fixed soon?
>   
>   
confirmed on my box it resulted in deleting all kernel modules.
(had to reinstall the kernel)
(make modules in /lib/modules/`uname -r`/build after make patch_kernel)
this was on fc6 x86_64


